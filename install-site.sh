#!/bin/bash

# Define the name of your Django project
PROJECT_NAME="EvenSight"

# Define the root directory of your cloned repository
REPO_ROOT_DIR="/path/to/your/cloned/repo" # Change this to the path where your repo is located

# Define the Bitnami specific paths
BITNAMI_BASE_DIR="/opt/bitnami"
BITNAMI_PYTHON="$BITNAMI_BASE_DIR/python/bin/python"
BITNAMI_PROJECTS_DIR="$BITNAMI_BASE_DIR/apps/django/django_projects/$PROJECT_NAME"
BITNAMI_MANAGE_PY="$BITNAMI_PROJECTS_DIR/manage.py"

# Set PYTHONPATH to include the directory where your Django project is located
export PYTHONPATH="$BITNAMI_PROJECTS_DIR:$PYTHONPATH"

# Prompt for database credentials
read -p "Enter your MariaDB database name: " db_name
read -p "Enter your MariaDB database user: " db_user
read -sp "Enter your MariaDB database password: " db_password
echo
read -p "Enter your MariaDB host (default 'localhost'): " db_host
db_host=${db_host:-localhost}
read -p "Enter your MariaDB port (default '3306'): " db_port
db_port=${db_port:-3306}

# Create the necessary directories
echo "Creating directories..."
mkdir -p "$BITNAMI_PROJECTS_DIR"
mkdir -p "$BITNAMI_PROJECTS_DIR/static"
mkdir -p "$BITNAMI_PROJECTS_DIR/media"

# Copy files from the repository root to the Bitnami project directory
echo "Copying files..."
cp -a "$REPO_ROOT_DIR/." "$BITNAMI_PROJECTS_DIR/"

# Navigate to the Bitnami project directory
cd "$BITNAMI_PROJECTS_DIR" || exit

# Check if the inner EvenSight directory exists
if [ ! -d "$BITNAMI_PROJECTS_DIR/$PROJECT_NAME" ]; then
    echo "The Django project directory $PROJECT_NAME does not exist."
    exit 1
fi

# Check if manage.py is present
if [ ! -f "$BITNAMI_MANAGE_PY" ]; then
    echo "The manage.py file does not exist."
    exit 1
fi

# Set the DJANGO_SETTINGS_MODULE environment variable
export DJANGO_SETTINGS_MODULE="$PROJECT_NAME.settings"

# Replace placeholders in settings.py with actual database credentials
echo "Configuring settings.py with database credentials..."
sed -i "s/'NAME': 'your-database-name'/'NAME': '$db_name'/g" "$BITNAMI_PROJECTS_DIR/$PROJECT_NAME/settings.py"
sed -i "s/'USER': 'your-database-user'/'USER': '$db_user'/g" "$BITNAMI_PROJECTS_DIR/$PROJECT_NAME/settings.py"
sed -i "s/'PASSWORD': 'your-database-password'/'PASSWORD': '$db_password'/g" "$BITNAMI_PROJECTS_DIR/$PROJECT_NAME/settings.py"
sed -i "s/'HOST': 'localhost'/'HOST': '$db_host'/g" "$BITNAMI_PROJECTS_DIR/$PROJECT_NAME/settings.py"
sed -i "s/'PORT': '3306'/'PORT': '$db_port'/g" "$BITNAMI_PROJECTS_DIR/$PROJECT_NAME/settings.py"

# Install project dependencies
echo "Installing project dependencies..."
$BITNAMI_PYTHON -m pip install -r requirements.txt

# Run Django checks
echo "Running Django checks..."
$BITNAMI_PYTHON $BITNAMI_MANAGE_PY check

# Run Django migrations
echo "Running Django migrations..."
$BITNAMI_PYTHON $BITNAMI_MANAGE_PY migrate

# Collect static files
echo "Collecting static files..."
$BITNAMI_PYTHON $BITNAMI_MANAGE_PY collectstatic --noinput

# Set proper permissions
echo "Setting proper permissions..."
chown -R bitnami:daemon "$BITNAMI_PROJECTS_DIR/static"
chown -R bitnami:daemon "$BITNAMI_PROJECTS_DIR/media"
find "$BITNAMI_PROJECTS_DIR/static" -type f -exec chmod 664 {} \;
find "$BITNAMI_PROJECTS_DIR/media" -type f -exec chmod 664 {} \;
find "$BITNAMI_PROJECTS_DIR/static" -type d -exec chmod 775 {} \;
find "$BITNAMI_PROJECTS_DIR/media" -type d -exec chmod 775 {} \;

# Restart Apache to apply changes
echo "Restarting Apache server..."
$BITNAMI_BASE_DIR/ctlscript.sh restart apache

echo "Django deployment script completed."
