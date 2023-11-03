#!/bin/bash

# Define the root directory of your Django project
REPO_ROOT_DIR="/opt/bitnami/apps/django/django_projects/EvenSight"
SETTINGS_PATH="$REPO_ROOT_DIR/EvenSight/settings.py"

# Define the settings module
export DJANGO_SETTINGS_MODULE="EvenSight.settings"

# Add the project directory to the PYTHONPATH
export PYTHONPATH="$REPO_ROOT_DIR:$PYTHONPATH"

# Navigate to the Django project directory
cd $REPO_ROOT_DIR || { echo "The Django project directory $REPO_ROOT_DIR does not exist."; exit 1; }

# Check if the settings file exists before attempting to use sed
if [ ! -f "$SETTINGS_PATH" ]; then
    echo "The settings file at $SETTINGS_PATH cannot be found."
    exit 1
fi

# Update the database settings in Django settings.py
DB_NAME="evensight"
DB_USER="root"
DB_PASS="bengerth" # Replace with the actual password
DB_HOST="localhost" # or your database host
DB_PORT="3306"

# Use sed to update settings.py with the new database configuration
sed -i "s/'ENGINE': 'django.db.backends.sqlite3'/'ENGINE': 'django.db.backends.mysql'/g" "$SETTINGS_PATH"
sed -i "s/'NAME': BASE_DIR \/ 'db.sqlite3'/'NAME': '$DB_NAME'/g" "$SETTINGS_PATH"
sed -i "s/'USER': ''/'USER': '$DB_USER'/g" "$SETTINGS_PATH"
sed -i "s/'PASSWORD': ''/'PASSWORD': '$DB_PASS'/g" "$SETTINGS_PATH"
sed -i "s/'HOST': ''/'HOST': '$DB_HOST'/g" "$SETTINGS_PATH"
sed -i "s/'PORT': ''/'PORT': '$DB_PORT'/g" "$SETTINGS_PATH"

# Install project dependencies
pip install -r requirements.txt

# Run Django checks
python manage.py check || { echo "Django checks failed."; exit 1; }

# Run Django migrations
python manage.py migrate || { echo "Django migrations failed."; exit 1; }

# Collect static files
python manage.py collectstatic --noinput || { echo "Collecting static files failed."; exit 1; }

# Grant permissions to the database user
mysql -u root -p -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'%' IDENTIFIED BY '$DB_PASS'; FLUSH PRIVILEGES;"

# Restart the server (this command may vary depending on how you serve your application)
# For example, if you're using Gunicorn with a service named 'myapp':
# systemctl restart myapp

echo "Django project setup completed successfully."
