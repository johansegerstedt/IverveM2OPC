<?php
/**
 * @author    Digia Commerce Oy
 * @copyright Copyright © 2018 Digia. All rights reserved.
 * @package   Digia_AvardaCheckout
 */
namespace Digia\AvardaCheckout\Test\Unit\Gateway\Request;

use Magento\Framework\TestFramework\Unit\Helper\ObjectManager;

/**
 * Class TransactionIdDataBuilderTest
 */
class TranIdDataBuilderTest extends \PHPUnit\Framework\TestCase
{
    /**
     * @var \Magento\Framework\TestFramework\Unit\Helper\ObjectManager
     */
    protected $objectManager;

    /**
     * @var \PHPUnit_Framework_MockObject_MockObject|\Magento\Payment\Model\Info
     */
    protected $paymentMock;

    /**
     * @var \PHPUnit_Framework_MockObject_MockObject|\Magento\Payment\Gateway\Data\PaymentDataObjectInterface
     */
    protected $paymentDataMock;

    /**
     * @var \PHPUnit_Framework_MockObject_MockObject|\Digia\AvardaCheckout\Gateway\Request\TranIdDataBuilder
     */
    protected $tranIdDataBuilder;

    public function setUp()
    {
        $this->objectManager = new ObjectManager($this);

        $this->paymentMock = $this->createMock(\Magento\Payment\Model\Info::class);

        $this->paymentDataMock = $this->createMock(\Magento\Payment\Gateway\Data\PaymentDataObjectInterface::class);
        $this->paymentDataMock->method('getPayment')->willReturn($this->paymentMock);

        $paymentDataHelperMock = $this->createMock(\Digia\AvardaCheckout\Helper\PaymentData::class);
        $paymentDataHelperMock->method('getTransactionId')->will($this->returnValue('1234'));

        $this->tranIdDataBuilder = $this->objectManager->getObject(
            \Digia\AvardaCheckout\Gateway\Request\TranIdDataBuilder::class,
            [
                'paymentDataHelper' => $paymentDataHelperMock,
            ]
        );
    }

    public function testBuild()
    {
        $this->paymentMock
            ->expects($this->once())
            ->method('__call')
            ->with(
                'setTransactionId',
                ['1234']
            );

        $result = $this->tranIdDataBuilder->build([
            'payment' => $this->paymentDataMock
        ]);

        $this->assertEquals([
            'TranId' => '1234',
        ], $result);
    }
}
