#!/bin/bash

# Define the source directory for your Django project
# Replace this with the actual path to your Django project
DJANGO_PROJECT_PATH="/path/to/your/django/project"
DJANGO_PROJECT_NAME="myproject" # Replace with your actual Django project name

# Define the Bitnami specific paths
BITNAMI_PYTHON="/opt/bitnami/python/bin/python"
BITNAMI_MANAGE_PY="/opt/bitnami/apps/django/django_projects/$DJANGO_PROJECT_NAME/manage.py"
BITNAMI_PROJECTS_PATH="/opt/bitnami/apps/django/django_projects"
BITNAMI_STATIC_PATH="/opt/bitnami/apps/django/django_projects/$DJANGO_PROJECT_NAME/static"
BITNAMI_MEDIA_PATH="/opt/bitnami/apps/django/django_projects/$DJANGO_PROJECT_NAME/media"

# Copy project to Bitnami projects directory
echo "Copying Django project to Bitnami projects directory..."
cp -r "$DJANGO_PROJECT_PATH" "$BITNAMI_PROJECTS_PATH/$DJANGO_PROJECT_NAME"

# Navigate to the Bitnami projects directory
cd "$BITNAMI_PROJECTS_PATH/$DJANGO_PROJECT_NAME" || exit

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
chown -R bitnami:daemon "$BITNAMI_STATIC_PATH"
chown -R bitnami:daemon "$BITNAMI_MEDIA_PATH"
find "$BITNAMI_STATIC_PATH" -type f -exec chmod 664 {} \;
find "$BITNAMI_MEDIA_PATH" -type f -exec chmod 664 {} \;
find "$BITNAMI_STATIC_PATH" -type d -exec chmod 775 {} \;
find "$BITNAMI_MEDIA_PATH" -type d -exec chmod 775 {} \;

# Restart Apache to apply changes
echo "Restarting Apache server..."
/opt/bitnami/ctlscript.sh restart apache

echo "Django deployment script completed."
