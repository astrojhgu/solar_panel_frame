size = 20;
width = 691;
height = 396;
l = 800;
H = height + 100;
foot_d = 150;
hole_dia=6;

// Aleksandr Saechnikov 17 june 2015

// extrusion_profile_20x20_v_slot(size=20, height=10);
// translate([30,0,0]) extrusion_profile_20x20_v_slot_smooth(size=20, height=10);

$fn = 30;

module extrusion_profile_20x20_v_slot(size = 20, height = 10)
{
    linear_extrude(height = height)
    {
        union()
        {
            extrusion_profile_20x20_v_slot_part(size);
            rotate([ 0, 0, 90 ]) extrusion_profile_20x20_v_slot_part(size);
            rotate([ 0, 0, 180 ]) extrusion_profile_20x20_v_slot_part(size);
            rotate([ 0, 0, 270 ]) extrusion_profile_20x20_v_slot_part(size);
        }
    }
}

module extrusion_profile_20x20_v_slot_part(size = 20)
{
    d = 5;
    r = 1.5;
    s1 = 1.8;
    s2 = 2;
    s3 = 6;
    s4 = 6.2;
    s5 = 9.5;
    s6 = 10.6;
    s7 = 20;

    reSize = size / 20; // Scalling

    k0 = 0;
    k1 = d * 0.5 * cos(45) * reSize;
    k2 = d * 0.5 * reSize;
    k3 = ((s7 * 0.5 - s3) - s1 * 0.5 * sqrt(2)) * reSize;
    k4 = s4 * 0.5 * reSize;
    k5 = (s7 * 0.5 - s3) * reSize;
    k6 = s6 * 0.5 * reSize;
    k7 = (s6 * 0.5 + s1 * 0.5 * sqrt(2)) * reSize;
    k8 = (s7 * 0.5 - s2) * reSize;
    k9 = s5 * 0.5 * reSize;
    k10 = s7 * 0.5 * reSize;
    k10_1 = k10 - r * (1 - cos(45)) * reSize;
    k10_2 = k10 - r * reSize;

    polygon(points =
                [[k1, k1], [k0, k2], [k0, k5], [k3, k5], [k6, k7], [k6, k8], [k4, k8], [k9, k10], [k10_2, k10],
                 [k10_1, k10_1], [k10, k10_2], [k10, k9], [k8, k4], [k8, k6], [k7, k6], [k5, k3], [k5, k0], [k2, k0]]);
}

module extrusion_profile_20x20_v_slot_smooth(size = 20, height = 10)
{
    linear_extrude(height = height)
    {
        difference()
        {
            union()
            {
                extrusion_profile_20x20_v_slot_part_smooth(size);
                rotate([ 0, 0, 90 ]) extrusion_profile_20x20_v_slot_part_smooth(size);
                rotate([ 0, 0, 180 ]) extrusion_profile_20x20_v_slot_part_smooth(size);
                rotate([ 0, 0, 270 ]) extrusion_profile_20x20_v_slot_part_smooth(size);
            }
            circle(r = (size / 20. * 2.5));
        }
    }
}

module extrusion_profile_20x20_v_slot_part_smooth(size = 20)
{
    r_center = 0.5 * size - 1.5 * size / 20;
    union()
    {
        translate([ r_center, r_center ]) circle(r = 1.5 * size / 20);
        extrusion_profile_20x20_v_slot_part(size);
    }
}

module end_cut(orient = 0, size = 20)
{
    rotate([ 0, 0, orient ]) translate([ -size / 2, size / 2, 0 ]) rotate([ 90, 0, 0 ]) translate([ 0, 0, -size / 2 ])
        linear_extrude(height = size * 2)
            polygon(points = [ [ -size, -size ], [ size * 2, -size ], [ -size, size * 2 ] ]);
}

module vslot_cut(L, B_cut = -1, T_cut = -1, x_holes = [], y_holes = []) difference()
{
    extrusion_profile_20x20_v_slot_smooth(height = L);

    if (B_cut >= 0)
    {
        end_cut(B_cut, size);
    }
    else
    {
        translate([ 0, 0, -size ]) end_cut(B_cut, size);
    }

    if (T_cut >= 0)
    {
        translate([ 0, 0, L ]) mirror([ 0, 0, 1 ]) end_cut(T_cut, size = size);
    }
    else
    {
        translate([ 0, 0, L + size ]) mirror([ 0, 0, 1 ]) end_cut(T_cut, size = size);
    }

    for (z = x_holes)
    {
        translate([ 0, 0, z ]) rotate([ 0, 90, 0 ]) cylinder(h = size, d = 5, center = true);
    }

    for (z = y_holes)
    {
        translate([ 0, 0, z ]) rotate([ 90, 0, 0 ]) cylinder(h = size, d = 5, center = true);
    }
}

union()
{
    //底盘主梁
    rotate([ -90, 0, 0 ]) vslot_cut(l, B_cut = -90, T_cut = -180,
                                    x_holes = [ size / 2, (l - height) / 2, (l + height) / 2 - 50, l - size / 2 ],
                                    y_holes = [ foot_d, l - foot_d ]);

    translate(v = [ width, 0, 0 ]) rotate([ -90, 0, 0 ]) vslot_cut(
        l, B_cut = -90, T_cut = -180, x_holes = [ size / 2, (l - height) / 2, (l + height) / 2 - 50, l - size / 2 ],
        y_holes = [ foot_d, l - foot_d ]);

    //横档

    translate(v = [ size / 2, (l - height) / 2, 0 ]) rotate([ 0, 90, 0 ])
        vslot_cut(width - size, B_cut = -90, T_cut = -180, y_holes = [(width - size) / 2]);

    translate(v = [ size / 2, (l + height) / 2 - 50, 0 ]) rotate([ 0, 90, 0 ])
        vslot_cut(width - size, B_cut = -90, T_cut = -180, x_holes = []);

    translate(v = [ size / 2, size / 2, 0 ]) rotate([ 0, 90, 0 ])
        vslot_cut(width - size, B_cut = -90, T_cut = -180, x_holes = []);

    translate(v = [ size / 2, l - size / 2, 0 ]) rotate([ 0, 90, 0 ])
        vslot_cut(width - size, B_cut = -90, T_cut = -180, x_holes = []);

    //两根立柱

    translate(v = [ 0, (l - height) / 2, size / 2 ])
        vslot_cut(height, B_cut = -90, T_cut = -180, x_holes = [height - size / 2]);

    translate(v = [ width, (l - height) / 2, size / 2 ])
        vslot_cut(height, B_cut = -90, T_cut = -180, x_holes = [height - size / 2]);

    //上方横档

    translate(v = [ size / 2, (l - height) / 2, height ]) rotate([ 0, 90, 0 ])
        vslot_cut(width - size, B_cut = -90, T_cut = -180, y_holes = [(width - size) / 2]);

    //斜撑

    translate([ 0, (l - height) / 2 + height - size / 2 * sqrt(2) + size / 2 + 1, size / 2 + 1 ]) rotate([ 45, 0, 0 ])
        translate([ 0, 0, -10 ]) vslot_cut(height * sqrt(2), B_cut = 90, T_cut = 90, y_holes = [ 175, 175 + 210 ]);

    translate([ width, (l - height) / 2 + height - size / 2 * sqrt(2) + size / 2 + 1, size / 2 + 1 ])
        rotate([ 45, 0, 0 ]) translate([ 0, 0, -10 ])
            vslot_cut(height * sqrt(2), B_cut = 90, T_cut = 90, y_holes = [ 175, 175 + 210 ]);

    //天线立柱

    translate([ width / 2, (l - height) / 2 - size, -size / 2 ])
        vslot_cut(H, y_holes = [ size / 2, height + size / 2 ]);
}
