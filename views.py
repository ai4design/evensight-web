from django.shortcuts import render

def home(request):
    return render(request, 'index.html')

def about(request):
    # You would have an 'about.html' template
    return render(request, 'about.html')

def services(request):
    # You would have a 'services.html' template
    return render(request, 'services.html')

def contact(request):
    # You would have a 'contact.html' template
    return render(request, 'contact.html')

def learn_more(request):
    # You would have a 'learn_more.html' template
    return render(request, 'learn_more.html')
