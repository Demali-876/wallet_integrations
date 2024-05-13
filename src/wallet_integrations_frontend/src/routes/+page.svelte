<script>
  import "../index.scss"; 
  import { createActor, canisterId } from 'declarations/wallet_integrations_backend';
  import { writable } from 'svelte/store';
  import { backend } from "$lib/canisters";
  import {idlFactory } from "declarations/wallet_integrations_backend/wallet_integrations_backend.did.js";
  import { AuthClient } from "@dfinity/auth-client";
  import { HttpAgent } from "@dfinity/agent";

  let actor = backend;
  let principal = writable("");
  let greeting = writable("");

  async function handleWhoAmI() {
      const principalResult = await actor.whoami();
      principal.set(principalResult.toString());
  };

  async function handleLogin(buttonId) {
    let authClient = await AuthClient.create();

    // Define window features outside to avoid redundancy
    const windowFeatures = `
        left=${window.screen.width / 2 - 525 / 2},
        top=${window.screen.height / 2 - 705 / 2},
        toolbar=0,location=0,menubar=0,width=525,height=705
    `;

    try {
        if (buttonId === "ii") {
            await new Promise((resolve, reject) => {
                authClient.login({
                    identityProvider: process.env.DFX_NETWORK === "ic"
                        ? "https://identity.ic0.app"
                        : `http://rdmx6-jaaaa-aaaaa-aaadq-cai.localhost:4943`,
                    onSuccess: () => {
                        setActorAfterLogin(authClient);
                        resolve();
                    },
                    onError: reject
                });
            });
        } else if (buttonId === "nfid") {
            const APP_NAME = "NFID example";
            const APP_LOGO = "https://nfid.one/icons/favicon-96x96.png";
            const CONFIG_QUERY = `?applicationName=${APP_NAME}&applicationLogo=${APP_LOGO}`;
            const identityProvider = `https://nfid.one/authenticate${CONFIG_QUERY}`;

            await authClient.login({
                identityProvider,
                onSuccess: () => setActorAfterLogin(authClient),
                windowFeatures,
                onError: (error) => {
                    console.error("NFID login failed:", error);
                    throw error; 
                }
            });
        } else if (buttonId == "plug") {
          const whitelist = [canisterId];
          const hasAllowed = await window.ic?.plug?.requestConnect({whitelist,});
          if (hasAllowed) {console.error("Connection was refused",error);}
          return;
        }
        console.log("Plug wallet is connected");
        if (!window.ic.plug?.agent) {
        console.log ("Oops! Failed to initialise the Agent...");
        return;
      }
      const backendActor = await window.ic.plug?.createActor({
      canisterId,
      idlFactory,
      });
      if (!backendActor) {
    console.log("Oops! Failed to initialise the integration Actor...");
    return;
  }
    } catch (error) {
        console.error("Login failed:", error);
    }
}

function setActorAfterLogin(authClient) {
    const identity = authClient.getIdentity();
    const agent = new HttpAgent({ identity });
    actor = createActor(canisterId, { agent });
}

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
    <button on:click={() => handleLogin('ii')}>Login with Internet Identity</button>
  </form>
  <br />
  <form>
    <button on:click={() => handleLogin('nfid')}>Login with NFID</button>
  </form>
  <br />
  <form>
    <button on:click={() => handleLogin('plug')}>Login with Plug</button>
  </form>
  <br />
  <form>
    <button type="button" on:click={handleWhoAmI}>Who Am I</button>
  </form>
  <section>{$principal}</section>
</main>

