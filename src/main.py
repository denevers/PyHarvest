import psycopg2
from rdflib import Graph

def main():
    g = Graph()
    context = "https://geoconnex.ca/id/catchment/02OJ*AB"
    g.parse(context)
    conn = psycopg2.connect("dbname=gsip user=gsip password=?gsip?")
    cur = conn.cursor()
    for stmt in g:
        # if the object is a literal, use the 
        pass
    else:
        cur.execute("INSERT INTO store.resource_triples (subj,pred,obj) VALUES (%s,%s,%s);",(stmt.subject(),stmt.predicate(),stmt.object()))
    
    
    
if __name__ == "__main__":
    main()