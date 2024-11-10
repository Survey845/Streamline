module 0xad3ac99a56757d51fc611b2ce98389dbbfe5fc6ecbac0948a6d578dc79567abb::SocialMedia {

    use aptos_framework::signer;
    use aptos_framework::vector;

    struct Post has store, key {
        content_id: u64,
        owner: address,
        upvotes: u64,
        downvotes: u64,
        is_visible: bool,
    }

    struct ChronologicalPosts has store {
        post_addresses: vector::Vector<address>, // A vector to store post addresses in chronological order
    }

    // Helper function to move a resource to the owner's account
    public fun move_to(owner: &signer, post: Post) {
        let owner_address = signer::address_of(owner);
        move_to_address(owner_address, post);
    }

    // Create a new post and add its address to the chronological list
    public fun create_post(owner: &signer, content_id: u64) {
        let post = Post {
            content_id,
            owner: signer::address_of(owner),
            upvotes: 0,
            downvotes: 0,
            is_visible: true,
        };

        // Add post address to the list of chronological posts
        let mut chron_posts=borrow_global_mut<ChronologicalPosts>(0x1); // Assuming a fixed address
        vector::push_back(&mut chron_posts.post_addresses, signer::address_of(owner));  // Add post to the list

        move_to(owner, post);
    }

    // Get the chronological list of post addresses
    public fun get_posts() : vector::Vector<address> {
        let chron_posts=borrow_global<ChronologicalPosts>(0x1); // Assuming a fixed address
        return chron_posts.post_addresses;
    }

    // Upvote a post and update visibility
    public fun upvote(post_owner: &signer, content_id: u64) {
        let post_address=signer::address_of(post_owner);
        let mut post=borrow_global_mut<Post>(post_address);  // Borrow mutably
        assert!(post.content_id==content_id,1);
        post.upvotes=post.upvote+1;
        update_visibility(&mut post);
    }

    // Downvote a post and update visibility
    public fun downvote(post_owner: &signer, content_id: u64) {
        let post_address=signer::address_of(post_owner);
        let mut post=borrow_global_mut<Post>(post_address);  // Borrow mutably
        assert!(post.content_id==content_id,1);
        post.downvotes=post.downvotes+1;
        update_visibility(&mut post);
    }

    // Update the visibility of the post based on votes
    fun update_visibility(post: &mut Post) {
        if (post.downvotes>=post.upvotes+2) {
            post.is_visible=false;
        } else {
            post.is_visible=true;
        }
    }

}