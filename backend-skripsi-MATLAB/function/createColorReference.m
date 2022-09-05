function createColorReference

rgbRef   = [243 243 242;
            056 061 150;
            214 126 044;
            115 082 068;
            200 200 200;
            070 148 073;
            080 091 168;
            194 150 130;
            160 160 160;
            175 054 060;
            193 090 099;
            098 122 157;
            122 122 121;
            231 199 031;
            094 060 108;
            087 108 067;
            085 085 085;
            187 086 149;
            157 188 064;
            133 128 177;
            052 052 052;
            008 133 161;
            224 163 046;
            103 189 170];
        
labRef = rgb2lab(rgbRef,'ColorSpace','adobe-rgb-1998');

colorRef.LAB = labRef;
colorRef.RGB = rgbRef;

save('colorRef.mat', 'colorRef');
disp('Done');