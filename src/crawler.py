#!/usr/bin/env python
# -*- coding: utf-8 -*-

import rdflib
import requests
import urllib.error

from rdflib import URIRef, Graph, plugin, exceptions
from rdflib.namespace import DCTERMS, RDF, RDFS
from rdflib.serializer import Serializer

from datetime import datetime

MASTER_NODE = "https://geoconnex.ca/id/LOD_Node/CAN_Hydro_LOD_Node?f=RDF"
CONNECTED_PREDICATE = URIRef("https://geoconnex.ca/id/properties/connectedTo")

# If you are not sure what format your file will be,
# you can use rdflib.util.guess_format() which will
# guess based on the file extension.

nodes = []


def main():
    crawl()


def crawl():
    """begin harvesting by finding connected nodes"""
    g = rdflib.Graph()

    # using requests to access node
    resp = requests.get(MASTER_NODE, verify=False)

    try:
        g.parse(data=resp.text, format="application/rdf+xml")
    except rdflib.exceptions.Error as e:
        print(e)
        return
    except urllib.error.HTTPError as e:
        print(e)
        return

    print("\n--- printing namespaces ---\n")
    ns = g.namespaces()
    for n in ns:
        print(n)

    connected_nodes = harvest_nodes(g)

    # Temporary hack until GSIP is updated with the correct
    # node URL https://cida-test.er.usgs.gov/chyld-pilot/info/LOD_Node/US_Hydro_LOD_Node

    # connected_nodes = ['https://cida-test.er.usgs.gov/chyld-pilot/info/LOD_Node/US_Hydro_LOD_Node']

    print("\n--- printing connected linked open data nodes ---\n")
    for i, node in enumerate(connected_nodes, start=1):
        print("{}: {}\n".format(i, node))

        g = rdflib.Graph()
        try:
            g.parse(node)
        except rdflib.exceptions.Error as e:
            print(e)
            continue
        except urllib.error.HTTPError as e:
            print(str(e) + "! " + e.url)
            continue

        harvest_triples(g)

    return json.dumps(
        {'timestamp': datetime.now().timestamp(), 'nodes': connected_nodes}
    )


def harvest_nodes(node):
    """harvest connected nodes"""

    for lnode in node.objects(predicate=CONNECTED_PREDICATE):
        if lnode not in nodes:
            nodes.append(lnode)

    return nodes


def harvest_triples(graph):
    """harvest triples from a given node"""
    print("\ngraph has %s statements" % len(graph))

    # print("\n--- printing raw triples ---\n")
    # for s, p, o in graph:
    #     print((s, p, o))

    # print("\n--- printing N3 triples ---\n")
    # n = graph.serialize(format="n3")
    # print(n.decode())

    print("\n--- printing RDF triples ---\n")
    n = graph.serialize(format="application/rdf+xml")
    print(n)

    # for s in graph.subjects(predicate=URIRef('http://schema.org/subjectOf'),
    #           object=rdflib.term.Literal('application/rdf+xml')):
    for s in graph.objects(predicate=URIRef('http://schema.org/subjectOf')):

        if (s, RDF.type, URIRef('https://opengeospatial.github.io/SELFIE/DataNode_FeatureLinkSet')) in graph:

            print("Parsing linked feartures from: {}\n".format(s))

            g = rdflib.Graph()

            g.parse(s, format="turtle")

            harvest_feature_relations(g)

            break


def harvest_feature_relations(graph):
    """harvest feature relations and store them"""

    print("harvesting feature relations....")
    # n = graph.serialize(format="n3")

    # print("\n--- printing N3 triples ---\n")
    # print(n.decode())

    # # Write triples to file in n3 format
    # f = open('data.n3', 'w')

    n = graph.serialize(format="turtle")

    print("\n--- printing triples ---\n")
    print(n)

    # Write triples to file in ttl format
    f = open('data.ttl', 'w')
    f.write(n)
    f.close()

    # Post to S3

    # Post triple to triple store
    # try:
    #     url = 'http://127.0.0.1:9999/blazegraph/sparql'
    #     payload = open('data.n3')
    #     headers = {'content-type': 'text/n3', 'Accept-Charset': 'UTF-8'}
    #     r = requests.post(url, data=payload, headers=headers)

    #     print('\n' + r.content.decode() + '\n')
    # except requests.exceptions.RequestException as e:
    #     print(e)
    #     sys.exit(1)


def validate_triples(triple):
    """validate triple"""
    for subj, pred, obj in triple:
        if (subj, pred, obj) not in triple:
            raise Exception("Invalid triple!")
        else:
            return True


if __name__ == "__main__":
    main()
