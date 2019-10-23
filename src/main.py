import psycopg2
from rdflib import Graph

def main():
    g = Graph()
    g.parse("https://geoconnex.ca/id/catchment/02OJ*AB")
    for stmt in g:
        print(stmt)
    
    
    
if __name__ == "__main__":
    main()