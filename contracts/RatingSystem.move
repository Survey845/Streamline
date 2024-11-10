module 0xad3ac99a56757d51fc611b2ce98389dbbfe5fc6ecbac0948a6d578dc79567abb::SocialMedia {

    use aptos_framework::signer;
    use std::vector;

    struct Post has store, key {
        content_id: u64,
        owner: address,
        upvotes: u64,
        downvotes: u64,
        is_visible: bool,
    }

    public fun create_post(owner: &signer, content_id: u64): Post {
        let post=Post {
            content_id,
            owner: signer::address_of(owner),
            upvotes: 0,
            downvotes: 0,
            is_visible: true,
        };
        move_to(owner, post);
        post
    }

    public fun upvote(post_owner: &signer, content_id: u64) acquires Post {
        let post=borrow_global_mut<Post>(post_owner);
        assert!(post.content_id == content_id,1);
        post.upvotes=post.upvotes+1;
        update_visibility(post);
    }

    public fun downvote(post_owner: &signer,content_id: u64) acquires Post {
        let post=borrow_global_mut<Post>(post_owner);
        assert!(post.content_id == content_id,1);
        post.downvotes=post.downvotes+1;
        update_visibility(post);
    }

    public fun get_upvotes(post_owner: &signer, content_id: u64): u64 acquires Post {
        let post=borrow_global<Post>(post_owner);
        assert!(post.content_id==content_id,1);
        post.upvotes
    }

    public fun get_downvotes(post_owner: &signer, content_id: u64): u64 acquires Post {
        let post=borrow_global<Post>(post_owner);
        assert!(post.content_id==content_id, 1);
        post.downvotes
    }

    public fun is_visible(post_owner: &signer, content_id: u64): bool acquires Post {
        let post=borrow_global<Post>(post_owner);
        assert!(post.content_id==content_id,1);
        post.is_visible
    }

    fun update_visibility(post: &mut Post) {
        if (post.downvotes>=post.upvotes+2) {
            post.is_visible=false;
        } else {
            post.is_visible=true;
        }
    }
}