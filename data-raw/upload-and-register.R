data_out =  paste0("https://github.com/cboettig/rfishbase_board/raw/main/fb_parquet_2023-05/", 
                   basename(fs::dir_ls("../rfishbase_board/fb_parquet_2023-05/")))


ids <- contentid::register(data_out, "hash-archive.carlboettiger.info")


data_out =  paste0("https://github.com/cboettig/rfishbase_board/raw/main/slb_parquet_2023-05/", 
                   basename(fs::dir_ls("../rfishbase_board/slb_parquet_2023-05/")))


ids <- contentid::register(data_out, "hash-archive.carlboettiger.info")
