#!/bin/bash

# Define the name of your Django project
PROJECT_NAME="<your_project_name>"

# Define the root directory of your cloned repository
REPO_ROOT_DIR="<repository_root_directory>"

# Define the Bitnami specific paths
BITNAMI_BASE_DIR="/opt/bitnami"
BITNAMI_PYTHON="$BITNAMI_BASE_DIR/python/bin/python"
BITNAMI_PROJECTS_DIR="$BITNAMI_BASE_DIR/apps/django/django_projects/$PROJECT_NAME"
BITNAMI_STATIC_DIR="$BITNAMI_PROJECTS_DIR/static"
BITNAMI_MEDIA_DIR="$BITNAMI_PROJECTS_DIR/media"
BITNAMI_MANAGE_PY="$BITNAMI_PROJECTS_DIR/manage.py"

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
mkdir -p "$BITNAMI_STATIC_DIR"
mkdir -p "$BITNAMI_MEDIA_DIR"

# Copy files from the repository root to the Bitnami project directory
echo "Copying files..."
cp -a "$REPO_ROOT_DIR/." "$BITNAMI_PROJECTS_DIR/"

# Navigate to the Bitnami project directory
cd "$BITNAMI_PROJECTS_DIR" || exit

# Replace placeholders in settings.py with actual database credentials
echo "Configuring settings.py with database credentials..."
sed -i "s/'NAME': 'your-database-name'/'NAME': '$db_name'/g" "$BITNAMI_PROJECTS_DIR/EvenSight/settings.py"
sed -i "s/'USER': 'your-database-user'/'USER': '$db_user'/g" "$BITNAMI_PROJECTS_DIR/EvenSight/settings.py"
sed -i "s/'PASSWORD': 'your-database-password'/'PASSWORD': '$db_password'/g" "$BITNAMI_PROJECTS_DIR/EvenSight/settings.py"
sed -i "s/'HOST': 'localhost'/'HOST': '$db_host'/g" "$BITNAMI_PROJECTS_DIR/EvenSight/settings.py"
sed -i "s/'PORT': '3306'/'PORT': '$db_port'/g" "$BITNAMI_PROJECTS_DIR/EvenSight/settings.py"

# Install project dependencies
echo "Installing project dependencies..."
$BITNAMI_PYTHON -m pip install -r requirements.txt

# Run Django migrations
echo "Running Django migrations..."
$BITNAMI_PYTHON $BITNAMI_MANAGE_PY migrate

# Collect static files
echo "Collecting static files..."
$BITNAMI_PYTHON $BITNAMI_MANAGE_PY collectstatic --noinput

# Set proper permissions
echo "Setting proper permissions..."
chown -R bitnami:daemon "$BITNAMI_STATIC_DIR"
chown -R bitnami:daemon "$BITNAMI_MEDIA_DIR"
find "$BITNAMI_STATIC_DIR" -type f -exec chmod 664 {} \;
find "$BITNAMI_MEDIA_DIR" -type f -exec chmod 664 {} \;
find "$BITNAMI_STATIC_DIR" -type d -exec chmod 775 {} \;
find "$BITNAMI_MEDIA_DIR" -type d -exec chmod 775 {} \;

# Restart Apache to apply changes
echo "Restarting Apache server..."
$BITNAMI_BASE_DIR/ctlscript.sh restart apache

echo "Django deployment script completed."
