
'''
with open("dol_mok.txt", 'r', encoding='utf-8') as f:
    lines = sorted(set(f.readlines()))
    with open("deduplicated_dol_mok.txt", 'w', encoding='utf-8') as f1:
         f1.write("".join(lines))



with open("o_mok.txt", 'r', encoding='utf-8') as f:
    lines = sorted(set(f.readlines()))
    with open("deduplicated_o_mok.txt", 'w', encoding='utf-8') as f1:
         f1.write("".join(lines))



with open("yuk_mok.txt", 'r', encoding='utf-8') as f:
    lines = sorted(set(f.readlines()))
    with open("deduplicated_yuk_mok.txt", 'w', encoding='utf-8') as f1:
         f1.write("".join(lines))



with open("sa_mok.txt", 'r', encoding='utf-8') as f:
    lines = sorted(set(f.readlines()))
    with open("deduplicated_sa_mok.txt", 'w', encoding='utf-8') as f1:
         f1.write("".join(lines))

'''

a = ["preposition.txt","sa_mok.txt","yuk_mok.txt","o_mok.txt","dol_mok.txt","names.txt","deduplicated_stone_war.txt"]
b = ["deduplicated_preposition.txt","deduplicated_sa_mok.txt","deduplicated_yuk_mok.txt","deduplicated_o_mok.txt","last_deduplicated_dol_mok.txt","deduplicated_names.txt","deduplicated_stone_war.txt"]

for i in range(7):
    with open(a[i], 'r', encoding='utf-8') as f:
        lines = sorted(list(map(lambda x:x.replace(" ",""),set(f.readlines() ))),key = lambda x:(len(x),x))
        with open(b[i], 'w', encoding='utf-8') as f1:
             f1.write("".join(lines))


