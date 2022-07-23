"""
Test Visitor count
"""

from flask import jsonify
from google.cloud import firestore
from main import get_visitor_count, save_visitor_data

def test_visitor_count():    
    print("Test #1: ")
    count_init = get_visitor_count()
    print("T1 Count = " + count_init)
    
    assert count_init >= 0
    print("T1 Value passed")
    assert type(count) is int 
    print("T1 Type passed")
    
    print("Test #2: ")
    save_visitor_data(count_init + 1)
    count = get_visitor_count()
    print("T2 Count = " + count)
    
    assert count > count_init
    print("T2 Value passed")
    
    print("Test #3: ")
    save_visitor_data(count_init + 1)
    count = get_visitor_count()
    print("T3 Count = " + count)
    
    assert count == count_init
    print("T3 Value passed")
    
if __name__ == "__main__":
    #test_visitor_count() # Need to setup permissions to run this function
    print('Hello Google!')   
