from django.db import models
from django.contrib.auth.models import User

# Extend the User model with a one-to-one link
class UserProfile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    bio = models.TextField(blank=True)
    website = models.URLField(blank=True)

    def __str__(self):
        return self.user.username

# Model for storing contact form submissions
class Contact(models.Model):
    name = models.CharField(max_length=255)
    email = models.EmailField()
    message = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Contact from {self.name}"

# Model for features or services offered
class Feature(models.Model):
    title = models.CharField(max_length=255)
    description = models.TextField()
    is_active = models.BooleanField(default=True)

    def __str__(self):
        return self.title

# Model for storing documentation or help articles
class Documentation(models.Model):
    title = models.CharField(max_length=255)
    content = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.title

# Model for user subscriptions or pricing plans
class Subscription(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    plan_name = models.CharField(max_length=255)
    price = models.DecimalField(max_digits=6, decimal_places=2)
    features = models.ManyToManyField(Feature)

    def __str__(self):
        return f"{self.user.username}'s subscription"
