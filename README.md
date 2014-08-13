## Rails API Token Authentication
We can use a token identifier for authenticate HTTP requests in our Back-end API. We should be aware of add a secure environment and Rails offers basically two authentication methods for the job, we are focusing in the most secure one which is authenticate_or_request_with_http_token method, which automatically checks the Authorization request header for a token and passes it as an argument to the given block. The best practice to implement this block is to place it inside a *before_action* to prevent users accessing data.

##### Benefits:

+ A user can have many tokens for use in different API clients. 

+ Better security, since vulnerability is limited to API access
and not the user’s account. 

+ We can add expire time or the option of regenerate tokens without alter the user’s account.

+ Best control for each token, so we can change the access rules.


##### HTTP Headers
Token must be provided on HTTP requests using the Authorization header.

	GET /episodes HTTP/1.1
	Host: localhost:3000
	Authorization: Token token=16d7d6089b8fe0c5e19bfe10bb156832


You can check a document for specifying HTTP Token Access Authentication. For more info, visit [here](http://tools.ietf.org/html/dra!-hammer-http-token-auth-01)

## Implementation

#### ApplicationController
For APIs, you may want to use **:null_session** instead of **:exception**

	protect_from_forgery with: :null_session

#### UserController
This is how the mentioned block example works for UsersController:


    before_action :authenticate

    #...

    protected

    def authenticate
      authenticate_or_request_with_http_token do |token, options|
        User.find_by(token: token)
      end
    end


#### User Model

Generating the token is pretty simple. One of the options you could go for is creating a method in your model and call it with a *before_create* callback. Here is an example:

    before_create :generate_token

    def generate_token
      begin
        self.token = SecureRandom.hex
      end while self.class.exists?(token: token)
    end


#### Encrypting Credentials

Another important part in authentication that you might want to take care is the credentials you are using to authenticate the client. We like using [bcrypt](https://github.com/codahale/bcrypt-ruby) gem which of Rails 4.x it's included in the gemfile as a comment. This gem helps you to encrypt credentials so user's password is not saved in plain text. 

#### Routes
Basically we should start our API with the V1 version that way we added a namespace for api and v1, this will generate this routes: **http://localhost:3000/api/v1/users** and by default will generate a json format request

    namespace :api do
      namespace :v1 do
        resources :users, defaults: { format: :json }
      end
    end


## Bonus (How to use curl commands)


If you want to test API requests using just the terminal you could use curl. 

**GET example:**

```
curl http://localhost:3000/api/v1/users
```

**GET example using token:**
```
curl -H "Authorization: Token token=my_first_user_token" http://localhost:3000/api/v1/users
```

**POST example:**

```
curl -d "user[name]=john&user[password]=mysecurepassword&user[password_confirmation]=mysecurepassword&user[email]=john@doe.com" -X POST localhost:3000/api/v1/users
```

### Notes: 

1. Since this API is already requiring a token, you might want to create your first user via rails console. This user's token will be used in the *GET example using token* above example.

2. In *POST example* example we are assuming that the model has *name*, *password_digest*, *token*, and *email* fields. The *password_digest* field was added according to [bcrypt] gem's usage.

### Authors

- Marco Gallardo
- Cesar Gomez
- Christian Rojas