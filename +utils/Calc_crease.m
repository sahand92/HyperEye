function crease_depth = Calc_crease(Ir)
    [l, w]=size(Ir);
    l1 = ceil(l/3);
    w1 = ceil(w/3);
    Ir_centre = Ir(l1:2*l1,w1:2*w1);
    crease_H = prctile(Ir_centre(:),5);
    crease_depth = prctile(Ir(:),95) - crease_H;
end

