package com.business.services; // ⚠️ Must match src/main/java/com/business/services

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

import java.util.Optional;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

// Imports based on your file tree structure
import com.business.entities.Product;           // Matches src/main/java/com/business/entities
import com.business.repositories.ProductRepository; // Matches src/main/java/com/business/repositories

@ExtendWith(MockitoExtension.class)
@DisplayName("Product Service Tests - Mockito")
public class ProductServiceTest {

    @Mock
    private ProductRepository productRepository;

    @InjectMocks
    private ProductServices productService;

    private Product testProduct1;
    private Product testProduct2;

    @BeforeEach
    public void setUp() {
        // Initialize test data before each test
        testProduct1 = new Product();
        testProduct1.setPid(1);
        testProduct1.setPname("Laptop");
        testProduct1.setPdescription("High-performance laptop");
        testProduct1.setPprice(1200.0);

        testProduct2 = new Product();
        testProduct2.setPid(2);
        testProduct2.setPname("Mouse");
        testProduct2.setPdescription("Wireless mouse");
        testProduct2.setPprice(25.0);
    }

    @Test
    @DisplayName("Test Get All Products - Verify Mock is Called")
    public void testGetAllProductsMockVerification() {
        // ARRANGE - Mock repository to return 2 products
        when(productRepository.findAll()).thenReturn(
            Stream.of(testProduct1, testProduct2).collect(Collectors.toList())
        );

        // ACT - Call the service method
        var products = productService.getAllProducts();

        // ASSERT - Verify repository method was called exactly once
        verify(productRepository, times(1)).findAll();
        assertEquals(2, products.size());
        System.out.println("✓ Test 1 Passed: getAllProducts() mock called once");
    }

    @Test
    @DisplayName("Test Get All Products - Verify Return Data")
    public void testGetAllProductsReturnData() {
        // ARRANGE
        when(productRepository.findAll()).thenReturn(
            Stream.of(testProduct1, testProduct2).collect(Collectors.toList())
        );

        // ACT
        var products = productService.getAllProducts();

        // ASSERT - Verify exact data returned
        assertEquals(2, products.size());
        assertEquals("Laptop", products.get(0).getPname());
        assertEquals(1200.0, products.get(0).getPprice());
        assertEquals("Mouse", products.get(1).getPname());
        assertEquals(25.0, products.get(1).getPprice());
        System.out.println("✓ Test 2 Passed: Correct product data returned");
    }

    @Test
    @DisplayName("Test Get All Products - Empty List Scenario")
    public void testGetAllProductsEmptyList() {
        // ARRANGE - Mock repository to return empty list
        when(productRepository.findAll()).thenReturn(java.util.Collections.emptyList());

        // ACT
        var products = productService.getAllProducts();

        // ASSERT - Verify empty list handling
        assertNotNull(products);
        assertEquals(0, products.size());
        verify(productRepository, times(1)).findAll();
        System.out.println("✓ Test 3 Passed: Empty product list handled correctly");
    }

    @Test
    @DisplayName("Test Add Product - Verify Mock Call with Argument Captor")
    public void testAddProductMockitoArgumentCaptor() {
        // ARRANGE
        ArgumentCaptor<Product> productCaptor = ArgumentCaptor.forClass(Product.class);
        when(productRepository.save(any(Product.class))).thenReturn(testProduct1);

        // ACT
        productService.addProduct(testProduct1);

        // ASSERT - Capture and verify the argument passed to save method
        verify(productRepository, times(1)).save(productCaptor.capture());
        Product capturedProduct = productCaptor.getValue();
        
        assertEquals("Laptop", capturedProduct.getPname());
        assertEquals(1200.0, capturedProduct.getPprice());
        System.out.println("✓ Test 4 Passed: ArgumentCaptor verified product save");
    }

    @Test
    @DisplayName("Test Get Product by ID - Successful Retrieval")
    public void testGetProductByIdSuccess() {
        // ARRANGE
        when(productRepository.findById(1)).thenReturn(Optional.of(testProduct1));

        // ACT
        productService.getProduct(1);

        // ASSERT
        verify(productRepository, times(1)).findById(1);
        System.out.println("✓ Test 5 Passed: Product retrieved by ID successfully");
    }

    @Test
    @DisplayName("Test Repository Not Called Multiple Times - Verify No Extra Calls")
    public void testRepositoryNotCalledMultipleTimes() {
        // ARRANGE
        when(productRepository.findAll()).thenReturn(
            Stream.of(testProduct1, testProduct2).collect(Collectors.toList())
        );

        // ACT
        productService.getAllProducts();

        // ASSERT - Verify repository was called exactly once, not more
        verify(productRepository, times(1)).findAll();
        verify(productRepository, never()).save(any());
        System.out.println("✓ Test 6 Passed: Verified no extra mock calls");
    }

    @Test
    @DisplayName("Test Mock Behavior Reset Between Calls")
    public void testMockResetBehavior() {
        // ARRANGE - First call
        when(productRepository.findAll()).thenReturn(
            Stream.of(testProduct1).collect(Collectors.toList())
        );

        // ACT - First call
        var firstCall = productService.getAllProducts();
        assertEquals(1, firstCall.size());

        // ARRANGE - Reset mock behavior for second call
        reset(productRepository);
        when(productRepository.findAll()).thenReturn(
            Stream.of(testProduct1, testProduct2).collect(Collectors.toList())
        );

        // ACT - Second call
        var secondCall = productService.getAllProducts();
        assertEquals(2, secondCall.size());

        // ASSERT
        System.out.println("✓ Test 7 Passed: Mock behavior reset successfully");
    }

    @Test
    @DisplayName("Test Mock Answer - Custom Behavior")
    public void testMockCustomAnswer() {
        // ARRANGE - Mock with custom answer/behavior
        when(productRepository.findAll()).thenAnswer(invocation -> {
            System.out.println("Mock method called with custom answer");
            return Stream.of(testProduct1, testProduct2).collect(Collectors.toList());
        });

        // ACT
        var products = productService.getAllProducts();

        // ASSERT
        assertEquals(2, products.size());
        verify(productRepository, times(1)).findAll();
        System.out.println("✓ Test 8 Passed: Mock custom answer executed");
    }
}