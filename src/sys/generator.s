
.include "cpctelera.h.s"

.area _DATA
;; Entity Values




.globl e_type_star


.globl cpct_disableFirmware_asm
.globl cpct_getScreenPtr_asm
.globl man_create_entity
.globl cpct_getRandom_mxor_u8_asm
.globl sys_generator_newStar
.globl man_search_for_space
.area _CODE

sys_generate_random:
    sub #70
ret

sys_generator_newStar:

    call cpct_getRandom_mxor_u8_asm    ;; generate random number of 200
    ld a, l
    ld l, #199
    cp l
    call nc, sys_generate_random

    ld e, a                           ;; save the number in E
    push de



    call cpct_getRandom_mxor_u8_asm      ;; generate random number of 3
    ld a, l
    and a, #03

             
                                       ;; put the random number negative
    ld b, a
    inc b                               ;; reduce the number by 1, to not get a 0 (-1,-3)
    
    ld a, (e_type_star)
    ld c, a
    push bc

    call man_search_for_space
        pop bc
        pop de
    call man_create_entity
   


ret


