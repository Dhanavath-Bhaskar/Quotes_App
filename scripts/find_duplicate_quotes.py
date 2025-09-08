import json
from collections import Counter

def load_quotes(filename):
    """Load quotes from a JSON file."""
    with open(filename, 'r', encoding='utf-8') as f:
        return json.load(f)

def find_duplicate_quotes(quotes):
    """Find and print duplicate quotes (case-insensitive, trimmed)."""
    texts = [q.get('text', '').strip().lower() for q in quotes if 'text' in q]
    counter = Counter(texts)
    found = False

    print("Duplicate Quotes:\n")
    for text, count in counter.items():
        if count > 1:
            found = True
            print(f'"{text}" is repeated {count} times. Details:')
            for q in quotes:
                if q.get('text', '').strip().lower() == text:
                    print(q)
            print()  # Extra line between groups

    if not found:
        print("No duplicate quotes found.")

def main():
    filename = "quotes_seed.json"  # Change this to your filename if different
    quotes = load_quotes(filename)
    find_duplicate_quotes(quotes)

if __name__ == "__main__":
    main()
