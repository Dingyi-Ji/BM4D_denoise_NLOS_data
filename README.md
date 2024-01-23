# BM4D_denoise_NLOS_data
利用BM4D算法对于共聚焦非视域成像（NLOS）所获得的数据进行去噪处理
由于NLOS数据的噪声来源多样，有高斯噪声，泊松噪声，以及其他类型噪声的存在，且需要保证数据不被模糊，因此传统的如高斯滤波等方法不合适

传统去噪方法可分为两种噪声算法，一种是非局部去噪方法Non-local method，是一种空间算法，另一种transform method是一种转换算法，将两者结合就是BM3D(Block-Matching and 3D filtering)
BM4D方法与BM3D算法思想类似，总体分为两大步，每一大步又分为三小步：相似块分组、协同滤波和聚合。
![image](https://github.com/Dingyi-Ji/BM4D_denoise_NLOS_data/assets/59365251/cf3ceab2-3bb3-4fb0-a20d-6144aee56a26)
