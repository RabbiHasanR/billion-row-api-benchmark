docker-compose.master_only load test. most of the request faild for too many clients already error in single database
{
  "request_type": "GET",
  "request_name": "/api/performance/purchases/latest/",
  "request_count": 18040,
  "failure_count": 14937,
  "median_response_time_ms": 720.0,
  "average_response_time_ms": 1059.3499719931308,
  "min_response_time_ms": 10.747075000836048,
  "max_response_time_ms": 34945.876878999115,
  "requests_per_second": 304.5086743743688
}