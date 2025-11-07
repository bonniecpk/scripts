import java.io.FileInputStream;
import java.nio.charset.StandardCharsets;

import org.w3c.dom.Document;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

import org.w3c.dom.Document;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathConstants;
import javax.xml.xpath.XPathFactory;
import javax.xml.transform.OutputKeys;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;
import java.io.StringWriter;
import java.io.File; // For writing to a file
import java.io.StringReader;
import org.xml.sax.InputSource;
import java.util.stream.Collectors;
import java.util.stream.IntStream;
import org.w3c.dom.NamedNodeMap;

public class XMLTester {
    public static void main(String[] args) {
        try {
            FileInputStream fio = new FileInputStream("/Users/pchui/Downloads/test.xml");
            byte[] byteContent = fio.readAllBytes();
            String content = new String(byteContent, StandardCharsets.UTF_8);
            DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
            factory.setNamespaceAware(false);
            factory.setValidating(false); // Optional: depends on if you need validation
            factory.setIgnoringElementContentWhitespace(true); // Optional
            DocumentBuilder builder = factory.newDocumentBuilder();
            Document rootElement = builder.parse(new InputSource(new StringReader(content)));

            XPath xpath = XPathFactory.newInstance().newXPath();
            NodeList nodeList = (NodeList) xpath.evaluate("/Edmx/DataServices/Schema", rootElement,
                    XPathConstants.NODESET);
            for (int i = 0; i < nodeList.getLength(); i++) {
                System.out.println(nodeList.item(i).getTextContent());
                Node node = (Node) xpath.evaluate("//EntityType", nodeList.item(i),
                        XPathConstants.NODE);
                if (node == null)
                    System.out.println("node is null");
                else
                    printNode(node);

                System.out.println("***********************************");
            }

            for (int j = 0; j < nodeList.getLength(); j++) {
                NodeList nodeList2 = (NodeList) xpath.evaluate("//Property", nodeList.item(j),
                        XPathConstants.NODESET);
                for (int i = 0; i < nodeList2.getLength(); i++) {
                    printNode(nodeList2.item(i));
                }
                System.out.println("---------------------------------------");
            }

            Node node = (Node) xpath.evaluate("//Property/@Name", nodeList.item(1),
                    XPathConstants.NODE);
            System.out.println(node.getNodeName() + "   " + node.getNodeValue());
            System.out.println(node.getTextContent());

            Node node2 = (Node) xpath.evaluate("//Property/@creatable", nodeList.item(1),
                    XPathConstants.NODE);
            System.out.println(node2.getNodeName() + "   " + node2.getNodeValue());
            System.out.println(node2.getTextContent());

            System.out.println("===========================================");

            NodeList nodeList3 = (NodeList) xpath.evaluate("/Edmx/DataServices/Schema/EntityType/Property", rootElement,
                    XPathConstants.NODESET);
            for (int j = 0; j < nodeList3.getLength(); j++) {
                printNode(nodeList3.item(j));

                // Node n = (Node) xpath.evaluate("/Edmx/DataServices/Schema",
                // nodeList3.item(j),
                // XPathConstants.NODE);
                // if (n == null)
                // System.out.println("n is null");
                // else {
                // System.out.println(n.getNodeName() + " " + n.getNodeValue());
                // System.out.println(n.getTextContent());
                // }

                // String val = (String) xpath.evaluate("./@Name", nodeList3.item(j),
                // XPathConstants.STRING);
                // System.out.println(val);

                Node n = (Node) xpath.evaluate("./@Name", nodeList3.item(j),
                        XPathConstants.NODE);
                if (n == null)
                    System.out.println("n is null");
                else {
                    System.out.println(n.getNodeName() + "   " + n.getNodeValue());
                    System.out.println(n.getTextContent());
                }

                // Node n = (Node) xpath.evaluate("//Property["+(j+1)+"]/@Name",
                // nodeList3.item(j),
                // XPathConstants.NODE);
                // if (n == null)
                // System.out.println("n is null");
                // else {
                // System.out.println(n.getNodeName() + " " + n.getNodeValue());
                // System.out.println(n.getTextContent());
                // }
            }
        } catch (Exception e) {
            System.out.println(e.getMessage());
        }
    }

    public static void printNode(Node node) {
        System.out.println(node.getNodeName() + "    "
                + IntStream.range(0, node.getAttributes().getLength()).mapToObj(node.getAttributes()::item)
                        .map(n -> n.getNodeName() + "=\"" + n.getNodeValue() + "\"")
                        .collect(Collectors.joining(" ", "[", "]")));
    }

    public static void printDocument(Node doc) {
        try {
            TransformerFactory tf = TransformerFactory.newInstance();
            Transformer transformer = tf.newTransformer();
            transformer.setOutputProperty(OutputKeys.OMIT_XML_DECLARATION, "no");
            transformer.setOutputProperty(OutputKeys.METHOD, "xml");
            transformer.setOutputProperty(OutputKeys.INDENT, "yes");
            transformer.setOutputProperty(OutputKeys.ENCODING, "UTF-8");
            transformer.setOutputProperty("{http://xml.apache.org/xslt}indent-amount", "4"); // For specific indentation

            StringWriter writer = new StringWriter();
            transformer.transform(new DOMSource(doc), new StreamResult(writer));
            System.out.println(writer.getBuffer().toString());

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}