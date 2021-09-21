require("./index.css");

import detectEthereumProvider from "@metamask/detect-provider";
import WalletConnect from "@walletconnect/client";
import QRCodeModal from "@walletconnect/qrcode-modal";

const { Elm } = require("./Main.elm");
const texture = require("./texture.json");

const CONTRACT = "0x531A67A6F75E93507a53276Eaf3677f895416d0e";
const CHAIN_ID = 1;

const newConnector = () =>
  new WalletConnect({
    bridge: "https://bridge.walletconnect.org",
    qrcodeModal: QRCodeModal,
  });

// eslint-disable-next-line fp/no-let
let connector = newConnector();

const getChain = async (provider) => {
  const chainId = await provider.request({
    method: "eth_chainId",
  });

  return Number(chainId);
};

(async () => {
  const provider = window.ethereum ? await detectEthereumProvider() : null;

  const hasWallet = Boolean(provider);

  const app = Elm.Main.init({
    node: document.getElementById("app"),
    flags: {
      texture,
      width: window.innerWidth,
      contract: CONTRACT,
      hasWallet,
    },
  });

  app.ports.disconnect.subscribe(() => {
    if (connector.connected) {
      connector.killSession();
    }
  });

  app.ports.connect.subscribe(() =>
    (async () => {
      if (connector.connected) {
        connector.killSession();
      }

      const chainId = await getChain(provider);

      if (chainId !== CHAIN_ID) {
        return app.ports.connectResponse.send(null);
      }

      const [account] = await provider.request({
        method: "eth_requestAccounts",
      });

      app.ports.connectResponse.send(account || null);
    })().catch(app.ports.connectResponse.send)
  );

  app.ports.wConnect.subscribe(() =>
    (async () => {
      if (connector.connected) {
        return app.ports.connectResponse.send(connector._accounts[0] || null);
      }

      // eslint-disable-next-line fp/no-mutation
      connector = newConnector();
      attachConnectorEvents(app);

      return connector.createSession();
    })().catch(app.ports.connectResponse.send)
  );

  app.ports.claim.subscribe((params) =>
    (async () => {
      const res = connector.connected
        ? connector.sendTransaction(params)
        : provider.request({
            method: "eth_sendTransaction",
            params: [params],
          });

      return app.ports.claimResponse.send(await res);
    })().catch((e) => app.ports.claimResponse.send(e))
  );

  app.ports.log.subscribe((x) => console.log(x));

  if (provider) {
    provider.on("accountsChanged", (_accounts) =>
      app.ports.clearWallet.send(null)
    );

    provider.on("chainChanged", (_chainId) => app.ports.clearWallet.send(null));
  }
})();

const attachConnectorEvents = (app) => {
  connector.on("connect", (error, payload) => {
    if (error) {
      return console.error(error);
    }

    const { accounts } = payload.params[0];

    app.ports.connectResponse.send(accounts[0] || null);
  });

  connector.on("disconnect", (error, _payload) => {
    if (error) {
      return console.error(error);
    }

    app.ports.clearWallet.send(null);
  });
};
