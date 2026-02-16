import React, { useEffect, useState } from "react";
import {
  Modal, Box, Typography, TextField, Button, MenuItem, CircularProgress
} from "@mui/material";

export default function ImageMetaModal() {
  const [open, setOpen] = useState(false);
  const [signedBlobId, setSignedId] = useState(null);
  const [shopId, setShopId] = useState("");
  const [sourceUrl, setSourceUrl] = useState("");
  const [shops, setShops] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    window.dispatchImageMetaModal = ({ signedId }) => {
      setSignedId(signedId);
      setOpen(true);
    };
  }, []);

  useEffect(() => {
    if (!open) return;
    setLoading(true);
    fetch("/api/shops")
      .then((res) => res.json())
      .then(setShops)
      .catch(() => alert("Shop取得失敗"))
      .finally(() => setLoading(false));
  }, [open]);

  const handleSave = async () => {
    try {
      const res = await fetch(`/api/image_credits`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token":
            document.querySelector('meta[name="csrf-token"]')?.content || "",
        },
        body: JSON.stringify({
          image_credit: {
            blob_id: signedBlobId,
            shop_id: Number(shopId),
            source_url: sourceUrl,
          },
        }),
      });

      if (!res.ok) throw new Error("保存失敗");
      handleClose();
    } catch (e) {
      alert("保存に失敗しました");
    }
  };

  const handleClose = () => {
    setOpen(false);
    setSignedId(null);
    setShopId("");
    setSourceUrl("");
  };

  return (
    <Modal open={open} onClose={handleClose}>
      <Box sx={{
        width: 400, p: 4, bgcolor: "background.paper", borderRadius: 2,
        boxShadow: 24, position: "absolute", top: "50%", left: "50%",
        transform: "translate(-50%, -50%)"
      }}>
        <Typography>Image by</Typography>

        {loading ? <CircularProgress /> : (
          <>
            <TextField
              select fullWidth label="Shop" value={shopId}
              onChange={(e) => setShopId(e.target.value)} margin="normal" required
            >
              <MenuItem value="">選択してください</MenuItem>
              {shops.map(shop => (
                <MenuItem key={shop.id} value={shop.id}>{shop.name}</MenuItem>
              ))}
            </TextField>

            <TextField
              label="出典URL" fullWidth value={sourceUrl}
              onChange={(e) => setSourceUrl(e.target.value)}
              placeholder="https://example.com" margin="normal"
            />

            <Box mt={2} display="flex" justifyContent="flex-end" gap={1}>
              <Button onClick={handleClose}>キャンセル</Button>
              <Button variant="contained" disabled={!shopId} onClick={handleSave}>保存</Button>
            </Box>
          </>
        )}
      </Box>
    </Modal>
  );
}
