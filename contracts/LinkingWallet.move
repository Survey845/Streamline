module 0xad3ac99a56757d51fc611b2ce98389dbbfe5fc6ecbac0948a6d578dc79567abb::WalletLinking {

    use 0x1::Signer;
    use 0x1::Option;
    use 0x1::Address;

    struct User has store {
        linked_wallet: Option<Address>,
    }

    const ERR_ALREADY_LINKED: u64 = 1;
    const ERR_INVALID_ADDRESS: u64 = 2;

   // Function to link wallet to the user
public fun link_wallet(user: &signer, wallet_address: address) {
       let user_data = borrow_global_mut<User>(Signer::address_of(user));

        if !Address::is_zero(wallet_address){
            abort(ERR_INVALID_ADDRESS);
        }

    Option::first(&user_data.linked_wallet).unwrap_or_else(|| { 
                // Check if the wallet is already linked
              if  Option::is_some(& user_data.linked_wallet) {
                    abort(ERR_ALREADY_LINKED); 
               }
                
                 user_data.linked_wallet = Some(wallet_address);
            });
}

    public fun get_linked_wallet(user: &signer): address {

        let user_data= borrow_global<User>(Signer::address_of(user));
        
     return Option::first(&user_data.linked_wallet).unwrap_or(Address::zero());
}