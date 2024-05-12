<script>
  import "../index.scss"; 
  import { createActor, canisterId } from 'declarations/wallet_integrations_backend';
  import { writable } from 'svelte/store';
  import { backend } from "$lib/canisters";
  import { AuthClient } from "@dfinity/auth-client";
  import { HttpAgent } from "@dfinity/agent";

  let actor = backend;
  let principal = writable("");
  let greeting = writable("");

  async function handleWhoAmI() {
      const principalResult = await actor.whoami();
      principal.set(principalResult.toString());
  };

  async function handleLogin() {
      let authClient = await AuthClient.create();
      await new Promise((resolve) => {
          authClient.login({
              identityProvider:
                  process.env.DFX_NETWORK === "ic"
                      ? "https://identity.ic0.app"
                      : `http://rdmx6-jaaaa-aaaaa-aaadq-cai.localhost:4943`,
              onSuccess: resolve,
          });
      });
      const identity = authClient.getIdentity();
      const agent = new HttpAgent({ identity });
      actor = createActor(canisterId, {
          agent,
          
      });
  };

  function onSubmit(event) {
      const name = event.target.name.value;
      backend.greet(name).then(response => {
        greeting.set(response);
      });
  }
</script>

<main>
  <img src="/logo2.svg" alt="DFINITY logo" />
  <br />
  <br />
  <form on:submit|preventDefault={onSubmit}>
    <label for="name">Enter your name: &nbsp;</label>
    <input id="name" alt="Name" type="text" />
    <button type="submit">Click Me!</button>
  </form>
  <section>{$greeting}</section>
  <form>
    <button type="button" on:click={handleLogin}>Login!</button>
  </form>
  <br />
  <form>
    <button type="button" on:click={handleWhoAmI}>Who Am I</button>
  </form>
  <section>{$principal}</section>
</main>

