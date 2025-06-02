from locust import HttpUser, task, between

class LoadTestUser(HttpUser):
    wait_time = between(1, 3)  # Wait time between requests

    @task
    def test_api(self):
        self.client.get("/api/performance/purchases/latest/")  # Replace with actual API endpoint