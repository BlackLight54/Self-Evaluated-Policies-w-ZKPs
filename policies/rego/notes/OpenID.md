OpenID and OpenID Connect are both open standards for authentication, but they work somewhat differently.

**OpenID**

OpenID is an open standard and decentralized authentication protocol. It allows users to be authenticated by certain co-operating sites (known as Relying Parties or RP) using a third-party service, eliminating the need for webmasters to provide their own login systems, and allowing users to log into multiple unrelated websites without having to have a separate identity and password for each.

Here's how OpenID works:

1. The user begins by attempting to access a resource that requires authentication (i.e., a login).

2. The website or application (Relying Party, RP) presents the user with the option to log in with their OpenID.

3. The user enters their OpenID identifier. This is usually a URL, like "username.example.com" or "example.com/username".

4. The RP resolves this URL to discover the OpenID provider's (OP's) server.

5. The user is redirected to their OpenID provider to authenticate. This may involve entering a password, or it could involve some other form of authentication like biometrics or multi-factor.

6. The OP then redirects the user back to the RP, along with the authentication response.

7. The RP can then access the claimed ID and validate it with the OP.

8. If the claimed ID is validated, the RP can grant access to the user.

**OpenID Connect**

OpenID Connect, on the other hand, is a simple identity layer on top of the OAuth 2.0 protocol, which allows computing clients to verify the identity of an end-user based on the authentication performed by an authorization server, as well as to obtain basic profile information about the end-user in an interoperable and REST-like manner.

Here's how OpenID Connect works:

1. The user tries to log into a website (Relying Party).

2. The RP creates an 'authentication request' and sends it to the OpenID Provider (OP).

3. The OP authenticates the user. This might involve asking the user for a username and password, or the user might already be authenticated.

4. The OP redirects the user back to the RP. The redirect includes an ID token and an access token. The ID token is a JWT (JSON Web Token), and it includes 'claims' about the identity of the user. The access token can be used to access APIs that the user has given their consent to.

5. The RP can validate the ID token locally based on the specification, which helps to ensure that the token wasn't tampered with during the redirect. 

6. Once the token is validated, the authentication is complete, and the RP can use the 'claims' in the ID token to get information about the user.

OpenID Connect allows for a variety of 'flows' or 'grants', which enable different types of clients (like a mobile app, a single page app, or a server-side app) to use the protocol in a secure manner. It provides a lot more features, such as the ability to refresh tokens, and the ability to request specific scopes, or pieces of user information.

While both protocols deal with the subject of authentication, OpenID Connect is significantly more advanced and feature-rich, offering more flexibility and control to developers and better catering to the modern web's needs.