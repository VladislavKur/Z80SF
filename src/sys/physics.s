
.include "cpctelera.h.s"

.area _DATA
where_to_draw:  .dw #0xffff              ;; place where i will draw
where_I_am:     .dw #0x0000                ;; this one is for move for the entities array calculating
pos_x:          .db #0xFF
pos_y:          .db #0xFF
color:          .db #0xFF
prevptr:        .db #0xFF

.globl cpct_disableFirmware_asm
.globl cpct_getScreenPtr_asm
.globl sys_physics_update
.globl entity_x
.globl entity_vx
.globl entities
.globl last_entity_pos_entities
.globl entity_prevptr
.globl man_set4Destruction_entity

.area _CODE

sys_physics_update:
    ld  hl, #entities
    ld (where_I_am),hl
    ld a,l
    add #54
    ld l, a
    ex de, hl

        jump:
        ld   bc, #0x0000
        ld   bc, (where_I_am)
        ld   ix, #0x000
        add  ix, bc 

        ld a, (ix)
        cp #1
        jr nz, dontReduceX

        ld b,#0x00
        ld  a, +1(ix)                   ;;a got the X of the entity
        ld  +5(ix),a
        sub +3(ix)                    ;; add the speed
        
        call c, man_set4Destruction_entity          ;; returb b value 00, didnt do anything --FF set it for destroy
            ld h, a
            ld  a, b
            cp #0xFF
            jr  z, willbedestroied              ;; this entity will be destroied
            ld a, h
        ld  +1(ix), a   
        willbedestroied:
        dontReduceX:

                      ;; put the added speed to the X position
                        
        
   

        ld hl, #where_I_am
        .rept 6
            inc (hl)
        .endm


    ld bc, (where_I_am)
    ld  a, c
    cp  e               ;;#checking if "WIam" is the same,
                                    ;; that means i am in already updated
                                    ;; the last entity
    jr  nz, jump                    ;; if i am not in the last entity, do next entity

    ld a, b
    cp d
    jr nz, jump                     ;; checking if last entity and where i am in same place, finishes the update
                                    ;; Loop of all entities
    





ret

sys_physics_1update:



ret