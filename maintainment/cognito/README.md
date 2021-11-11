# Usuarios
Existen dos scripts para crear y mantener los usuarios.
el script [create-cognito-users.sh](./create-cognito-users.sh) permite crear los usuarios de cognito ingresando en el modo administrador (ver ./load-session-token.sh).
Los usuarios que serán creados están especificados en [users-data.json](./users-data.json) en formato json. Todos los usuarios con las propiedades que se agreguen allí serán agregados a los usuarios de cognito.
Cada usuario podrá tener usuario

# Prueba 1

* Probar la conexión vía curl para intentar obtener el id_token por fuera del postman

Según lo visto [acá](https://stackoverflow.com/questions/37941780/what-is-the-rest-or-cli-api-for-logging-in-to-amazon-cognito-user-pools) y [acá](https://dev.to/mcharytoniuk/using-aws-cognito-app-client-secret-hash-with-go-8ld) el problema es que cognito no permite la conexión desde afuera cuando está configurado el client secret, aparentemente necesita una encriptación en base64 para que tome como valido el token.

aws cognito-idp admin-initiate-auth --user-pool-id us-west-2_aaaaaaaaa --client-id 3n4b5urk1ft4fl3mg5e62d9ado --auth-flow ADMIN_NO_SRP_AUTH --auth-parameters USERNAME=jane@example.com,PASSWORD=password

https://dev.to/mcharytoniuk/using-aws-cognito-app-client-secret-hash-with-go-8ld

https://www.47lining.com/paas/docs/preview/preview-docs-audience/latest/preview-docs/user-guide/auth/

https://aws.amazon.com/premiumsupport/knowledge-center/cognito-unable-to-verify-secret-hash/

https://sanderknape.com/2020/08/amazon-cognito-jwts-authenticate-amazon-http-api/

# Cognito User Flow

https://docs.aws.amazon.com/cognito/latest/developerguide/signing-up-users-in-your-app.html

