img = imread('C:\Users\ckocb_000\Thesis\BACKUP\Hollywood_KeyFrames\actioncliptest00011.avi_0067.jpg');


A = [
      1.0045
    0.0003
   -2.0071
    0.0001
    1.0043
   -0.5355
    0.0000
    0.0000
    1.0043
   -0.0003
   -1.9503
    0.0001
    1.0034
   -0.4549
   -0.0000
    0.0000
    1.0043
   -0.0006
   -1.8221
    0.0002
    1.0033
   -0.4778
    0.0000
   -0.0000
    1.0042
    0.0001
   -1.9438
    0.0001
    1.0039
   -0.5003
   -0.0000
    0.0000];

for k = 1:10
for i = 1:8:size(A)
    
    h = [ A(i) A(i+1) A(i+2)
        A(i+3) A(i+4) A(i+5)
        0 0 1]
    img = imTrans(img,h);

end
end
figure;
imshow(img);


    
    
    