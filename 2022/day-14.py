import re

def rock_into_set(filename):
    lines = [line.strip() for line in open(filename).readlines()]
    rock_set = set()
    for line in lines:
        rock_ends = []
        coordinates = re.findall('\d*,\d*', line)
        for c in coordinates:
            match = re.match('(\d*)(?:,)(\d*)', c)
            point = (int(match.group(1)), int(match.group(2)))
            rock_ends.append(point)
        for n, point in enumerate(rock_ends):
            if n == len(rock_ends)-1:
                pass
            else:
                this_hori = point[0]
                this_vert = point[1]
                next_hori = rock_ends[n+1][0]
                next_vert = rock_ends[n+1][1]
                if this_hori == next_hori:
                    #horizontals are the same, we compare the verticals
                    if this_vert < next_vert:
                        all_between = range(this_vert, next_vert+1)
                    else:
                        all_between = range(next_vert, this_vert+1)
                    for vert in all_between:
                        rock_set.add((this_hori, vert))     
                else:
                    #we compare horizontals
                    if this_hori<next_hori:
                        all_between = range(this_hori, next_hori+1)
                    else:
                        all_between = range(next_hori, this_hori+1)
                    for hori in all_between:
                        rock_set.add((hori,this_vert))
    return rock_set

def find_extents(rocks):
    max_x = sorted([n[0] for n in rocks], reverse=True)[0]
    min_x = sorted([n[0] for n in rocks])[0]
    max_y = sorted([n[1] for n in rocks], reverse=True)[0]
    min_y = sorted([n[1] for n in rocks])[0]
    return [min_x,max_x,min_y,max_y]

def falling_sand(rocks, source):
    sand_set = set()
    lowest_rock = sorted([n[1] for n in rocks], reverse=True)[0]
    falling_into_abyss = False
    while falling_into_abyss == False:
        sand = (source[0], source[1]+1)
        while True:
            test_sand = (sand[0], sand[1]+1)
            #if we can't move you down, down-left, or down-right, add to sandset
            if (test_sand in rocks) or (test_sand in sand_set):
                test_sand = (sand[0]-1, sand[1]+1)
                if (test_sand in rocks) or (test_sand in sand_set):
                    test_sand = (sand[0]+1, sand[1]+1)
                    if (test_sand in rocks) or (test_sand in sand_set):
                        sand_set.add(sand)
                        break
            #else (you can move)
            sand = test_sand
            if sand[1]>lowest_rock:
                falling_into_abyss = True
                break
    draw(rocks,sand_set)
    return len(sand_set)

def draw(rocks,sand=set()):
    extents = find_extents(rocks)
    print(extents)
    for y in range(extents[2],extents[3]+1):
        out = ''
        for x in range(extents[0],extents[1]+1):
            if (x,y) in rocks:
                out = out + '#'
            elif (x,y) in sand:
                out = out + 'o'
            else:
                out = out + ' '
        print(out)
        
rocks = rock_into_set('Dec14')

draw(rocks)

#print(falling_sand(rocks, (500,0)))


#425 is too low
