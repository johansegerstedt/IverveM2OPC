<?php
/**
 * @author    Digia Commerce Oy
 * @copyright Copyright © 2018 Digia. All rights reserved.
 * @package   Digia_AvardaCheckout
 */
namespace Digia\AvardaCheckout\Gateway\Request;

use Magento\Payment\Gateway\Helper\SubjectReader;
use Magento\Payment\Gateway\Request\BuilderInterface;

/**
 * Class CustomerDataBuilder
 */
class CustomerTokenDataBuilder implements BuilderInterface
{
    /**
     * CustomerToken is a key associated with customer details.
     */
    const CUSTOMER_TOKEN = 'CustomerToken';

    /**
     * @var \Magento\Customer\Model\Session
     */
    protected $customerSession;

    /**
     * CustomerTokenDataBuilder constructor.
     *
     * @param \Magento\Customer\Model\Session $customerSession
     */
    public function __construct(
        \Magento\Customer\Model\Session $customerSession
    ) {
        $this->customerSession = $customerSession;
    }

    /**
     * @inheritdoc
     */
    public function build(array $buildSubject)
    {
        if (!$this->customerSession->isLoggedIn()) {
            return [];
        }
        
        $customerToken = $this->customerSession
            ->getCustomerData()
            ->getCustomAttribute('avarda_customer_token');

        if ($customerToken === null || $customerToken->getValue() === null) {
            return [];
        }

        return [
            self::CUSTOMER_TOKEN => $customerToken->getValue(),
        ];
    }
}
