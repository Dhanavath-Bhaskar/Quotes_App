import re

# List of your 100 categories
categories = [
    "Focus", "Health", "Forging Ahead", "Resilience", "Perseverance", "Charity", "Wisdom", "Natural", "Humor", "Nature",
    "Dreams", "Positivity", "Discipline", "Music", "Memories", "Change", "Mindset", "Authenticity", "Culture", "Justice",
    "Kindness", "Learning", "Listening", "Mindfulness", "Overcoming Obstacles", "Patience", "Peace", "Prosperity", "Reflection",
    "Responsibility", "Trust", "Wealth", "Action", "Adventure", "Art", "Childhood", "Confidence", "Decision", "Determination",
    "Education", "Endings", "Family", "Freedom", "Growth", "Honesty", "Hope", "Humility", "Imagination", "Inclusion", "Innovation",
    "Integrity", "Leadership", "Opportunity", "Risk", "Sacrifice", "Self-Discovery", "Self-Improvement", "Service", "Silence",
    "Simplicity", "Teamwork", "Time", "Travel", "Value", "Vision", "Wellness", "Youth", "New Beginnings", "Parenting", "Passion",
    "Spirituality", "Wisdom of Age", "Diversity", "Equality", "Gratitude", "Happiness & Joy", "Life", "Community", "Purpose",
    "Self-Love", "Philosophy", "Peace & Inner Calm", "Courage", "Belief", "Giving", "Failure", "Faith", "Motivation & Achievement",
    "Worry & Anxiety", "Love", "Creativity & Inspiration", "Success", "Balance", "Friendship", "Mindfulness & Letting Go",
    "Hard Work", "Relationships & Connection", "Forgiveness", "Strength", "Empathy"
]

filename = "quotes_seed.json"

# Read all lines from the file
with open(filename, "r", encoding="utf-8") as f:
    lines = f.readlines()

for category_to_find in categories:
    category_start_lines = []
    inside_object = False
    for idx, line in enumerate(lines, start=1):
        if re.match(r'\s*{', line):
            object_start = idx
            inside_object = True
        if inside_object and f'"kCategory": "{category_to_find}"' in line:
            category_start_lines.append(object_start)
            inside_object = False
    print(f'Category "{category_to_find}" appears at the following starting line numbers:')
    print(category_start_lines)
    print()
