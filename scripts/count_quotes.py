import json
from collections import Counter

# Read your quotes_seed.json file
with open('quotes_seed.json', 'r', encoding='utf-8') as f:
    quotes = json.load(f)

# Extract categories and count them
categories = [q['kCategory'] for q in quotes]
category_counts = Counter(categories)

# Print result
for category, count in category_counts.most_common():
    print(f"{category}: {count}")
