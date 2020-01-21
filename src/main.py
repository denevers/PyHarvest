import psycopg2
from rdflib import Graph
from rdflib.term import Literal,URIRef
import os

def main():
    g = Graph()
    context = "https://geoconnex.ca/id/catchment/02OJ*AB"
    g.parse(context)
    # environment variable must be in the form
    # host=<host> dbname=<database> user=<user> password=<password>
    # the harvertest expect a schema named 'store'
    connstring = os.environ['GSIP_HARV_CON_STR']

    conn = psycopg2.connect(connstring)
    cur = conn.cursor()
    # delete previous context
    cur.execute("DELETE FROM store.t_resource where ctx_id in (select r_id FROM store.resources where uri = %s)",(context,))
    cur.execute("DELETE FROM store.t_literal where ctx_id in (select r_id FROM store.resources where uri = %s)",(context,))

    for subject,predicate,obj in g:
        if type(obj) == Literal:
            cur.execute("INSERT INTO store.literal_triples (subj,pred,lit,lang,type,ctx) VALUES (%s,%s,%s,%s,%s,%s);",(subject.toPython(),
                                                                                                                       predicate.toPython(),
                                                                                                                       obj.toPython(),
                                                                                                                       obj.language,
                                                                                                                       obj.datatype,
                                                                                                                       context))
        else:
            cur.execute("INSERT INTO store.resource_triples (subj,pred,obj,ctx) VALUES (%s,%s,%s,%s);",(subject.toPython(),predicate.toPython(),obj.toPython(),context))
    conn.commit()
    cur.close()
    conn.close()
            
                        
           
    #    pass
    #else:
    
    
    
if __name__ == "__main__":
    main()