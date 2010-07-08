//
//  SeriouslyXML.m
//  Seriously
//
//  Created by Corey Johnson on 6/30/10.
//  Copyright 2010 Probably Interactive. All rights reserved.
//

//#import <stdio.h>
//#import <libxml/parser.h>
//#import <libxml/tree.h>
//
//#import "SeriouslyXML.h"
//
//@implementation SeriouslyXML
//
//
//#define SERIOUSLY_XML_DEFAULT_TEXT_LABEL "text"
//#define SERIOUSLY_XML_DEFAULT_ATTRS_LABEL "attrs"
//#define SERIOUSLY_XML_MAX_LABEL_LENGTH 1000
//
//static char *appendNamespaceToName(const char *name, xmlNs *ns) {
//    char *prefixElementName = nil;
//    size_t prefixElementNameSize = 0;
//    if (ns && ns->prefix) {
//        prefixElementNameSize = strlen((const char *)name) + 1; // 1 is added because of the namespace colon :
//        prefixElementName = alloca(prefixElementNameSize + 1);
//        memset(prefixElementName, 0, prefixElementNameSize + 1);
//        strcat(prefixElementName, (const char *)ns->prefix);
//        strcat(prefixElementName, ":");
//    }
//    
//    
//    size_t elementNameSize = prefixElementNameSize + strlen(name);
//    char *elementName = malloc(elementNameSize + 1); // You got to free this later dude!
//    memset(elementName, 0, elementNameSize + 1);
//    if (prefixElementName) strcat(elementName, prefixElementName);
//    strcat(elementName, name);
//    
//    return elementName;
//}
//
//static void createTable(lua_State *L, xmlNode *node, char *textLabel, char *attrsLabel) {
//    for (; node; node = node->next) {
//        switch (node->type) {
//            case SERIOUSLY_XML_ELEMENT_NODE: {
//                
//                // Combined the namespace with the node name
//                char *elementName = appendNamespaceToName((const char *)node->name, node->ns);
//                
//                lua_newtable(L);
//                
//                // Push attribute table
//                lua_pushstring(L, attrsLabel);
//                lua_newtable(L);
//                
//                // Attributes ?
//                xmlAttrPtr attribute = node->properties;
//                for(; attribute; attribute = attribute->next) {
//                    xmlChar* attributeValue = xmlNodeListGetString(node->doc, attribute->children, YES);
//                    char *attributeName = appendNamespaceToName((const char *)attribute->name, attribute->ns);
//                    lua_pushstring(L, (const char *)attributeValue);                    
//                    lua_setfield(L, -2, attributeName);
//                    free(attributeName);
//                    xmlFree(attributeValue);
//                }
//                
//                // Set attribute table
//                lua_rawset(L, -3);
//                
//                createTable(L, node->children, textLabel, attrsLabel);
//                
//                // If the element name already exists in the table, make it an array
//                lua_getfield(L, -2, elementName); // get current value
//                
//                if (lua_isnil(L, -1)) { // not on stack yet, everything is cool
//                    lua_pop(L, 1); // pop nil off
//                    lua_setfield(L, -2, elementName);
//                }
//                else {
//                    lua_getfield(L, -1, attrsLabel); // is the current occupant a node or an array?
//                    BOOL existsAsArray = lua_isnil(L, -1);
//                    lua_pop(L, 1); // pop off nil, or the attr table.
//                    
//                    if (!existsAsArray) {
//                        lua_newtable(L);
//                        lua_insert(L, -2); // move the former node on top of the new array
//                        lua_rawseti(L, -2, 1); // add it to the new array
//                        
//                        lua_pushvalue(L, -1); // the new table
//                        lua_setfield(L, -4, elementName); // add the new table to the parent array
//                    }
//                    
//                    lua_insert(L, -2); // move the table above the new node
//                    lua_rawseti(L, -2, lua_objlen(L, -2) + 1); // ad the new node
//                    lua_pop(L, 1); // remove the table array
//                }
//                
//                free(elementName);
//                
//                break;
//            }
//            case SERIOUSLY_XML_TEXT_NODE:
//                if (xmlIsBlankNode(node)) continue;
//                
//                lua_pushstring(L, textLabel);
//                lua_pushstring(L, (const char *)node->content);
//                lua_rawset(L, -3);
//                
//                break;                
//            default:
//                // I have no idea what these things are... XML is for weirdos
//                luaL_error(L, "UNKNOWN NODE TYPE %d", node->type);
//                break;
//        }
//    }
//}
//
//- (id)parse:(NSString *)string {
//    xmlDocPtr doc;
//    
//    int xmlLength = [string lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
//    char *xml = alloca(xmlLength);
//    strncpy(xml, luaL_checkstring(L, 1), xmlLength);
//    
//    char textLabel[SERIOUSLY_XML_MAX_LABEL_LENGTH] = SERIOUSLY_XML_DEFAULT_TEXT_LABEL;
//    char attrsLabel[SERIOUSLY_XML_MAX_LABEL_LENGTH] = SERIOUSLY_XML_DEFAULT_ATTRS_LABEL;
//    
//    if (lua_istable(L, 2)) {
//        // check for text label
//        lua_getfield(L, 2, SERIOUSLY_XML_DEFAULT_TEXT_LABEL);
//        if (!lua_isnil(L, -1)) {
//            int length = lua_objlen(L, -1);
//            memset(textLabel, 0, SERIOUSLY_XML_MAX_LABEL_LENGTH);
//            strncpy(textLabel, luaL_checkstring(L, -1), MIN(length, SERIOUSLY_XML_MAX_LABEL_LENGTH - 1));
//        } 
//        lua_pop(L, 1); // pop off the custom text label, or nil
//        
//        // check for attrs label
//        lua_getfield(L, 2, SERIOUSLY_XML_DEFAULT_ATTRS_LABEL);
//        if (!lua_isnil(L, -1)) {
//            int length = lua_objlen(L, -1);
//            memset(attrsLabel, 0, SERIOUSLY_XML_MAX_LABEL_LENGTH);
//            strncpy(attrsLabel, luaL_checkstring(L, -1), MIN(length, SERIOUSLY_XML_MAX_LABEL_LENGTH - 1));
//        }
//        lua_pop(L, 1); // pop off the custom text label, or nil
//        
//        lua_pop(L, 1); // pop the custom label table off the stack (just making room!)
//    }
//    
//    lua_pop(L, 1); // pop the xml off the stack (just making room!)
//    
//    doc = xmlReadMemory(xml, xmlLength, "noname.xml", NULL, 0);
//    if (doc != NULL) {
//        xmlNode *root_element = xmlDocGetRootElement(doc);
//        
//        lua_newtable(L); // creates table to return
//        createTable(L, root_element, textLabel, attrsLabel);
//    } 
//    else {
//        luaL_error(L, "Unable open for parsing xml");
//    }
//    
//    xmlFreeDoc(doc);    
//}
//
//@end
