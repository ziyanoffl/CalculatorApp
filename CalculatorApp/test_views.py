# tests.py
from django.test import TestCase
from django.urls import reverse


class HomeViewTest(TestCase):
    def test_home_view(self):
        # Get the response from the home view
        response = self.client.get(reverse('home'))
        # Check that the status code is 200 (OK)
        self.assertEqual(response.status_code, 200)
        # Check that the template used is index.html
        self.assertTemplateUsed(response, 'index.html')

    def test_home_view_with_invalid_method(self):
        # Try to post data to the home view
        response = self.client.post(reverse('home'), data={'name': 'Alice'})
        # Check that the status code is 405 (Method Not Allowed)
        self.assertEqual(response.status_code, 405)
