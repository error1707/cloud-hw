resource "yandex_api_gateway" "api-gateway" {
  name        = "api"
  spec = <<-EOT
    openapi: "3.0.0"
    info:
      version: 1.0.0
      title: Test API
    paths:
      /task:
        post:
          summary: Create task
          operationId: createTask
          parameters:
            - name: model
              in: query
              description: What model use in task
              required: true
          x-yc-apigateway-integration:
            type: cloud_functions
            function_id: ${yandex_function.create-task.id}
            service_account_id: ${yandex_iam_service_account.sa.id}
        get:
          summary: List all tasks
          operationId: listTasks
          x-yc-apigateway-integration:
            type: cloud_functions
            function_id: ${yandex_function.list-tasks.id}
            service_account_id: ${yandex_iam_service_account.sa.id}
      /task/{task_id}:
        get:
          summary: Get task by id
          operationId: getTask
          parameters:
            - in: path
              name: task_id
              schema:
                type: integer
              required: true
          x-yc-apigateway-integration:
            type: cloud_functions
            function_id: ${yandex_function.get-task.id}
            service_account_id: ${yandex_iam_service_account.sa.id}
  EOT
}