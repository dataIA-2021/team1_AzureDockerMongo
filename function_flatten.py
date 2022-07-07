def flatten_json(y):
    out = {}

    def flatten(x, name=''):
        if type(x) is dict:
            for a in x:
                flatten(x[a], name + a + '_')
        elif type(x) is list:
            i = 0
            for a in x:
                flatten(a, name + str(i) + '_')
                i += 1
        else:
            out[name[:-1]] = x

    flatten(y)
    
    return out

def extract_key_from_flatten_thread(flatten_thread, keyword):
    #result = [(key, value) for key, value in flatten_thread.items() if key.endswith(keyword)]
    result = [(value) for key, value in flatten_thread.items() if key.endswith(keyword)]

    return(result)

