    .file    "code.s"
    .option nopic
    .text
    .align    2
    .globl    main
    .type     main, @function
main:
    li      a0, 0xF6FFF070
    li      a1, 0x00000041
    j       main2
end:
    li      a7, 1
end2:
    j       end2
main2:
    sb      a1, 0(a0)            # 0xF6FFF070に0x00000041（ASCIIコードの'A'）をストアする
main3:
    j       main3                # ここでループして終了
