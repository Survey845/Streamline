import { WalletSelector } from "./WalletSelector";

export function Header() {
  return (
    <div className="flex items-center justify-between px-4 py-2 max-w-screen-xl mx-auto w-full flex-wrap">
      <p className="text-2xl font-bold text-gray-800">A Social Media Dapp</p>
      <div className="flex items-center justify-center gap-2 flex-wrap">
        <WalletSelector />
      </div>
    </div>
  );
}
