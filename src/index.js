import React from 'react'
import ReactDOM from 'react-dom'
import App from './components/App/App'
import 'bootstrap/dist/css/bootstrap.min.css'
import { ChainId, DAppProvider} from '@usedapp/core'
import {ApolloClient, InMemoryCache, ApolloProvider} from "@apollo/client"

const client = new ApolloClient({
  uri: 'https://api.thegraph.com/subgraphs/name/rarity-adventure/rarity', //https://api.thegraph.com/subgraphs/name/rarity-adventure/rarity
  cache: new InMemoryCache()
})

const config = {
  readOnlyChain : [ChainId.Fantom],
  readOnluUrls:{
    [ChainId.Fantom]: "https://rpc.ftm.tools/"
  },
  multicallAddresses: {
    1337: "0xdc85396592f0F466224390771C861EE3957a3ff4" 
  }
}

ReactDOM.render(
    <React.StrictMode>
        <DAppProvider config={config}>
          <ApolloProvider client={client}>
            <App/>
          </ApolloProvider>
        </DAppProvider>
    </React.StrictMode>,
    document.getElementById('root')
);