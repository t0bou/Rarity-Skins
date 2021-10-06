import { useEthers } from '@usedapp/core'
import { Button, Container, Navbar, Row, Col } from 'react-bootstrap'
import { Connected } from '../Connected'

export default function App(){
    const { activateBrowserWallet, account } = useEthers()
    const style = {color : "#ffffff", backgroundColor: "#000000"}
    return(
        <div className="App" style={{color : "#ffffff", backgroundColor: "#000000"}}>
            <Navbar bg="dark">
                <Navbar.Brand style={{color : "#ffffff"}}>&nbsp;&nbsp;Rarity Summoner's Rare Skins&nbsp;&nbsp;</Navbar.Brand>
                <Navbar.Brand style={{color : "#ffffff"}} href={"https://medium.com/@tobou/introducing-rarity-skins-7833b4e54806"}>
                    about
                </Navbar.Brand>
            </Navbar>
            <Container style={{color : "#ffffff", backgroundColor: "#000000"}}>
                <Row>
                    <Col>
                        <br/>
                        <h1>Adventure with style !</h1>
                        {!account && <><br/>&nbsp;&nbsp;<Button onClick={() => activateBrowserWallet()}>Connect Wallet</Button></>}
                        {account && <Connected account={account}/>}

                        {/* ugly cheap fix to background-color nor filling the whole screen */}
                        {Array(100).fill(<br/>)} 
                    </Col>
                </Row>
            </Container>
        </div>
    )
}