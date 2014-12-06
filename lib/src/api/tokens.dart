part of directcode.services.api;

@Group("/tokens")
class TokenService {
  TokenManager manager = new TokenManager()..load();
  
  @RequiresToken()
  @Route("/current")
  current(@Attr() String token) {
    return {
      "token": token,
      "permissions": manager.allTokens[token]
    };
  }
  
  @RequiresToken(permissions: const ["tokens.reload"])
  @Route("/reload")
  reload() {
    loadTokens();
    return {
      "status": "success"
    };
  }
  
  @RequiresToken(permissions: const ["tokens.create"])
  @Route("/create")
  create(@Attr("token") String creatorToken, @Decode() CreateTokenRequest request) {
    var token = generateToken();
    if (!request.permissions.every((it) => tokens[creatorToken].contains(it))) {
      throw new ErrorResponse(HttpStatus.UNAUTHORIZED, {
        "message": "tried to create a token with more permissions than the creator has"
      });
    }
    manager.addToken(token, permissions: request.permissions);
    manager.save();
    return {
      "token": token,
      "permissions": request.permissions
    };
  }
  
  @RequiresToken(permissions: const ["tokens.revoke"])
  @Route("/revoke")
  revoke(@Decode() RevokeTokenRequest request) {
    manager.removeToken(request.token);
    manager.save();
  }
  
  @RequiresToken(permissions: const ["tokens.list"])
  @Route("/list")
  list() {
    return manager.allTokens.keys;
  }
}

class CreateTokenRequest {
  @Field()
  List<String> permissions = [];
}

class RevokeTokenRequest {
  @Field()
  String token;
}