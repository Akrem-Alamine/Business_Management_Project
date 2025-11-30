package com.business.services; // ⚠️ Must match src/main/java/com/business/services

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.Mockito.when;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.times;

import java.util.stream.Collectors;
import java.util.stream.Stream;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

// Imports based on your file tree structure
import com.business.entities.Product;           // Matches src/main/java/com/business/entities
import com.business.repositories.ProductRepository; // Matches src/main/java/com/business/repositories

@ExtendWith(MockitoExtension.class)
public class ProductServiceTest {

    @Mock
    private ProductRepository productRepository;

    @InjectMocks
    private ProductServices productService; // Using ProductServices instead of ProductServiceImpl

    @Test
    public void testRetrieveAllProducts() {
        // ARRANGE
        Product product1 = new Product();
        product1.setPid(1);
        product1.setPname("Laptop");
        product1.setPdescription("Electronics");
        product1.setPprice(1200.0);
        
        Product product2 = new Product();
        product2.setPid(2);
        product2.setPname("Mouse");
        product2.setPdescription("Electronics");
        product2.setPprice(25.0);
        
        when(productRepository.findAll()).thenReturn(
            Stream.of(product1, product2).collect(Collectors.toList())
        );

        // ACT
        assertEquals(2, productService.getAllProducts().size());
        
        // ASSERT
        System.out.println("Test Passed: Service returned 2 products.");
    }
}