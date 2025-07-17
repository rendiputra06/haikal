import difflib

def compare_texts(transkrip, referensi):
    # Split per kata
    trans_words = transkrip.strip().split()
    ref_words = referensi.strip().split()
    matcher = difflib.SequenceMatcher(None, ref_words, trans_words)
    result = []
    for tag, i1, i2, j1, j2 in matcher.get_opcodes():
        if tag == 'equal':
            result.extend([{'word': w, 'status': 'benar'} for w in ref_words[i1:i2]])
        elif tag == 'replace' or tag == 'delete':
            result.extend([{'word': w, 'status': 'salah'} for w in ref_words[i1:i2]])
        elif tag == 'insert':
            # Kata tambahan di transkrip
            result.extend([{'word': w, 'status': 'tambahan'} for w in trans_words[j1:j2]])
    return result 