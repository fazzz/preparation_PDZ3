#!/usr/bin/gawk -f

BEGIN{
    FIELDWIDTHS = "6 5 1 4 1 3 1 1 4 1 3 8 8 8 6 6 6 4"
}

($1~/ATOM/ && $8~/A/ && ($9 >= 306 && $9 <= 415)) || ($1~/ATOM/ && $8~/B/) || ($1 ~/TER/){
    print $0
}
