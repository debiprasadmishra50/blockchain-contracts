import React from "react";
import Header from "./Header";
import { Container } from "semantic-ui-react";
import Head from "next/head";

const Layout = ({ children }) => {
    return (
        <Container
            style={{ backgroundColor: "#efefef", padding: "0px 0px 10px 0px" }}
        >
            <Head>
                <link
                    async
                    rel="stylesheet"
                    href="https://cdn.jsdelivr.net/npm/semantic-ui@2/dist/semantic.min.css"
                />
            </Head>
            <Header />
            {children}
        </Container>
    );
};

export default Layout;
