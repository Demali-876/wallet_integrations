  import Principal "mo:base/Principal";
actor {
  public query func greet(name : Text) : async Text {
    return "Hello, " # name # "!";
  };
  public shared (msg) func whoami() : async Principal {
        msg.caller
    };
  public shared query({caller}) func greetnfid(name : Text) : async Text {
    return "Hello, " # name # "! " # "Your PrincipalId is: " # Principal.toText(caller);
  };


};

