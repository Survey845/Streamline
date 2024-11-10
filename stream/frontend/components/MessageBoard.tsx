import { useEffect, useState } from "react";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import { useWalletClient } from "@thalalabs/surf/hooks";
import { toast } from "@/components/ui/use-toast";
import { aptosClient } from "@/utils/aptosClient";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { getMessageContent } from "@/view-functions/getMessageContent";
import { MESSAGE_BOARD_ABI } from "@/utils/message_board_abi";

const JWT = "PINATA_JWT"; // Pinata JWT for authentication

export function MessageBoard() {
  const { client } = useWalletClient();
  const queryClient = useQueryClient();
  const [messageContent, setMessageContent] = useState<string>("");
  const [newMessageContent, setNewMessageContent] = useState<string>("");
  const [image, setImage] = useState<File | null>(null);
  const [imageCID, setImageCID] = useState<string | null>(null);

  const { data } = useQuery({
    queryKey: ["message-content"],
    refetchInterval: 10000,
    queryFn: async () => {
      try {
        const content = await getMessageContent();
        return { content };
      } catch (error: any) {
        toast({
          variant: "destructive",
          title: "Error",
          description: error.message,
        });
        return { content: "" };
      }
    },
  });

  const uploadToIPFS = async (file: File) => {
    try {
      const data = new FormData();
      data.append("file", file);

      const request = await fetch("https://api.pinata.cloud/pinning/pinFileToIPFS", {
        method: "POST",
        headers: {
          Authorization: `Bearer ${JWT}`,
        },
        body: data,
      });

      const response = await request.json();
      setImageCID(response.IpfsHash);

      toast({
        title: "Image Uploaded",
        description: `Image uploaded to IPFS with CID: ${response.IpfsHash}`,
      });
    } catch (error) {
      toast({
        variant: "destructive",
        title: "Error",
        description: "Image upload to IPFS failed",
      });
      console.error(error);
    }
  };

  const onClickButton = async () => {
    if (!newMessageContent || !client) return;

    try {
      // Upload image to IPFS if available
      if (image) {
        await uploadToIPFS(image);
      }

      // Concatenate the message content and image CID
      const combinedMessage = `${newMessageContent}::${imageCID || ""}`;

      // Pass the combined message as a single argument
      const committedTransaction = await client.useABI(MESSAGE_BOARD_ABI).post_message({
        type_arguments: [],
        arguments: [combinedMessage],  // Single concatenated string
      });

      const executedTransaction = await aptosClient().waitForTransaction({
        transactionHash: committedTransaction.hash,
      });

      // Invalidate the query to refresh message content
      queryClient.invalidateQueries({
        queryKey: ["message-content"],
      });

      toast({
        title: "Success",
        description: `Transaction succeeded, hash: ${executedTransaction.hash}`,
      });
    } catch (error) {
      toast({
        variant: "destructive",
        title: "Error",
        description: "Transaction failed",
      });
      console.error(error);
    }
  };

  useEffect(() => {
    if (data?.content) {
      setMessageContent(data.content);
    }
  }, [data]);

  return (
    <div className="flex flex-col gap-6">
      <h4 className="text-lg font-medium">Message content: {messageContent}</h4>
      <Input
        disabled={!client}
        placeholder="Enter your message"
        onChange={(e) => setNewMessageContent(e.target.value)}
      />
      <input
        type="file"
        accept="image/*"
        disabled={!client}
        onChange={(e) => setImage(e.target.files?.[0] || null)}
      />
      <Button
        disabled={!client || !newMessageContent || newMessageContent.length === 0 || newMessageContent.length > 100}
        onClick={onClickButton}
      >
        Write
      </Button>
    </div>
  );
}
