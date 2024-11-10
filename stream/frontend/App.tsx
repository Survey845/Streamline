import { useWallet } from "@aptos-labs/wallet-adapter-react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Header } from "@/components/Header";
import { TopBanner } from "@/components/TopBanner";
import { NetworkInfo } from "@/components/NetworkInfo";
import { AccountInfo } from "@/components/AccountInfo";
import { TransferAPT } from "@/components/TransferAPT";
import { MessageBoard } from "@/components/MessageBoard"; // Updated import

function App() {
  const { connected } = useWallet();

  return (
    <>
      <TopBanner />
      <Header />
      <div className="flex items-center justify-center flex-col">
        {connected ? (
          <Card>
            <MessageBoard />
            <CardContent className="flex flex-col gap-10 pt-6">
              <NetworkInfo />
              <AccountInfo />
              <TransferAPT />
            </CardContent>
          </Card>
        ) : (
          <CardHeader>
            <CardTitle>To get started, connect a wallet</CardTitle>
          </CardHeader>
        )}
      </div>
    </>
  );
}

export default App;
